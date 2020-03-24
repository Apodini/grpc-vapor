//
//  File.swift
//  
//
//  Created by Michael Schlicker on 21.03.20.
//

import Foundation
import CLIKit
import SourceKittenFramework

struct FileAnaylzer {
    let sourceCode: String?
    var structure: Structure?
    var rootNode: Node?

    init(path: Path) {
        guard let file = File(path: path.string),
            let structure = try? Structure(file: file),
            let data = structure.description.data(using: .utf8),
            let rootNode = try? JSONDecoder().decode(Node.self, from: data) else {
                self.sourceCode = nil
                return
        }
        self.structure = structure
        self.rootNode = rootNode
        self.sourceCode = try? String(contentsOf: path.url, encoding: .utf8)
    }

    func analyze() -> AnalyzeResult? {
        guard let results = rootNode?.childNodes?.compactMap({ analyzeNode(node: $0) }),
            var firstResult = results.first else { return nil }
        firstResult.mergeResults(Array(results.dropFirst()))
        return firstResult
    }

    private func analyzeNode(node: Node, parentName: String? = nil) -> AnalyzeResult? {
        guard [.class, .struct, .extension].contains(node.kind),
            let name = node.name else { return nil }

        let fullName = (parentName.map { "\($0)." } ?? "") + name

        var result = AnalyzeResult()

        let isGRPCService = node.inheritedTypes?.contains(where: { $0.name == "GRPCService" }) ?? false

        let methods = node.childNodes?
            .filter { $0.kind == .method }
            .compactMap(analyzeMethod) ?? []

        if isGRPCService || methods.count > 0 {
            let service = Service(fullName: fullName, isService: isGRPCService, methods: methods)
            result.services = [fullName: service]
        }

        let isGRPCModel = node.inheritedTypes?.contains(where: { $0.name == "GRPCModel" }) ?? false

        let attributeCases = node.childNodes?
            .filter { $0.kind == .enum && $0.name == "GRPCAttributes" }
            .first
            .map { $0.childNodes?.compactMap(analyzeAttributeCase) ?? [] }

        let vars = node.childNodes?
            .filter { $0.kind == .var }
            .compactMap(analyzeAttribute) ?? []

        if isGRPCModel || vars.count > 0 || attributeCases != nil {
            let model = Model(fullName: fullName, isModel: isGRPCModel, attributes: vars, attributeCases: attributeCases ?? [])
            result.models = [fullName: model]
        }

        let childResults = node.childNodes?.compactMap { analyzeNode(node: $0, parentName: fullName) }
        if let childResults = childResults {
            result.mergeResults(childResults)
        }

        guard !result.models.isEmpty || !result.services.isEmpty else { return nil }
        return result
    }

    private func analyzeAttributeCase(structure: Node) -> Attribute? {
        guard structure.kind == .enumcase,
            let enumcase = structure.childNodes?.filter({ $0.kind == .enumelement }).first,
            let name = enumcase.name else { return nil }
        guard let sourceCode = sourceCode,
            enumcase.elements?.count == 1,
            let subelement = enumcase.elements?.first,
            subelement.kind == .initexpr,
            let offset = subelement.offset,
            let length = subelement.length  else { return Attribute(name: name, id: nil, swiftType: nil) }
        let startIndex = sourceCode.index(sourceCode.startIndex, offsetBy: offset - 1)
        let endIndex = sourceCode.index(startIndex, offsetBy: length)
        let exprString = sourceCode[startIndex..<endIndex]
        let fieldNumber = Int(exprString)
        return Attribute(name: name, id: fieldNumber, swiftType: nil)
    }

    private func analyzeAttribute(structure: Node) -> Attribute? {
        guard structure.kind == .var,
            let name = structure.name,
            let type = structure.type else { return nil }
        return Attribute(name: name, swiftType: type)
    }

    private func analyzeMethod(structure: Node) -> Method? {
        // Extract method information from format:
        // methodName(req: )
        guard .method == structure.kind,
            let parameters = structure.childNodes?.filter({ $0.kind == .parameter }),
            parameters.count == 1,
            let parameterType = parameters.first?.type?.removeSpaces() else { return nil }

        // Decode CallType and Input Type
        // Encoded as GRPCRequestType<InputType> or GRPCRequestType<InputType, OutputType>
        // with prefix the containing the RequestType and containing being Input and OutputTypes
        let prefixSplit = parameterType.split(separator: "<")
        guard prefixSplit.count == 2,
        let callType = CallType(requestType: String(prefixSplit[0])) else { return nil }
        let suffixSplit = prefixSplit[1].split(separator: ">")
        guard suffixSplit.count == 1 else { return nil }

        // Decode method name and parameter name of request
        // Encoded as methodName(parameterName: )
        guard let nameParts = structure.name?.removeSpaces().split(separator: "("),
            nameParts.count >= 2,
            let name = nameParts.first,
            let parameterName = nameParts[1].split(separator: ":").first else { return nil }

        // Decode InputType and OutputType from suffix
        let inputType: String
        let outputType: String
        switch callType {
        case .unaryCall, .clientStream:
            // Encoded as GRPCRequestType<InputType> -> EventLoopFuture<OutputType>
            guard let returnType = structure.type?.removeSpaces() else { return nil }
            let returnPrefixSplit = returnType.split(separator: "<")
            guard returnPrefixSplit.count == 2,
                returnPrefixSplit[0] == "EventLoopFuture" else { return nil }
            let returnSuffixSplit2 = returnPrefixSplit[1].split(separator: ">")
            guard returnSuffixSplit2.count == 1 else { return nil }
            inputType = String(suffixSplit[0])
            outputType = String(returnSuffixSplit2[0])
        case .serverStream, .bidirectionalStream:
            // Encoded as GRPCRequestType<InputType, OutputType>
            let inoutSplit = suffixSplit[0].split(separator: ",")
            guard inoutSplit.count == 2 else { return nil }
            inputType = String(inoutSplit[0])
            outputType = String(inoutSplit[1])
        }

        return Method(name: String(name),
                      parameterName: String(parameterName),
                      type: callType,
                      inputType: inputType,
                      outputType: outputType)
    }
}
