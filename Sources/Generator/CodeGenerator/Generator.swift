//
//  Generator.swift
//  
//
//  Created by Michael Schlicker on 19.01.20.
//

import Foundation

struct Generator {
    let maxFielNo = 536_870_911
    let outputPath: URL

    let servicePath: URL
    var modelPath: URL
    var protoPath: URL
    var protoFilePath: URL

    let indent = "  "
    let emptyLine = "\n"    

    init(outputPath: URL) {
        self.outputPath = outputPath
        servicePath = outputPath//.appendingPathComponent("Services").appendingPathComponent("Generated")
        modelPath = outputPath//.appendingPathComponent("Models").appendingPathComponent("Generated")
        protoPath = outputPath//.appendingPathComponent("Proto")
        protoFilePath = protoPath.appendingPathComponent("application.proto")
    }

    func generate(from application: GRPCApplication) {
        generateProtoFile(application: application)
        generateServices(services: application.services)
        application.models.forEach(generateModelExtension)
    }

    func generateProtoFile(application: GRPCApplication) {
        _ = try? FileManager.default.createDirectory(at: protoPath, withIntermediateDirectories: true, attributes: nil)
        let protoFile = FileWriter()
        protoFile.println("syntax = \"proto3\";")
        protoFile.println()
        protoFile.println("option swift_prefix=\"_\";")
        for service in application.services {
            protoFile.println("service \(service.protoName) {")
            protoFile.startIndent()
            for method in service.methods {
                protoFile.println("rpc \(method.name.capitalizedFirstCharacter) (\(method.protoInputType)) returns (\(method.protoOutputType)) {}")
            }
            protoFile.endIndent()
            protoFile.println("}")
            protoFile.println()
        }
        application.models.forEach { generateProtoModel(model: $0, protoFile: protoFile) }
        protoFile.println("message Nil { }")
        do {
            try protoFile.text.write(to: protoFilePath, atomically: false, encoding: .utf8)
        } catch let error {
            print("Failed: \(error)")
        }
    }

    func generateProtoModel(model: ProtoModel, protoFile: FileWriter) {
        protoFile.println("message \(model.protoSuffixName) {")
        protoFile.startIndent()
        model.attributes.sorted().forEach { generateProtoAttribute(attribute: $0, protoFile: protoFile) }
        if !model.subModels.isEmpty { protoFile.println() }
        model.subModels.forEach { generateProtoModel(model: $0.value, protoFile: protoFile)}
        protoFile.endIndent()
        protoFile.println("}")
        protoFile.println()
    }

    func generateProtoAttribute(attribute: ProtoAttribute, protoFile: FileWriter) {
        // TODO: add or remove prefixes with custom types
        switch attribute.type {
        case let .optional(optionalType):
            protoFile.println("oneof \(attribute.protoOptionalName) {")
            protoFile.startIndent()
            protoFile.println("\(optionalType.protoString) \(attribute.name) = \(attribute.fieldNumber);")
            protoFile.println("Nil no_\(attribute.name) = \(maxFielNo-attribute.fieldNumber);")
            protoFile.endIndent()
            protoFile.println("}")
        default:
            protoFile.println("\(attribute.type.protoString) \(attribute.name) = \(attribute.fieldNumber);")
        }
    }

    func generateModels(models: [Model]) {
        // create output directory
        _ = try? FileManager.default.createDirectory(at: modelPath, withIntermediateDirectories: true, attributes: nil)
        for model in models {
            generateModel(model: model)
        }
        // for each service write
    }

    func generateModel(model: Model) {
        let filename = "\(model.fullName)+Generated.swift"
        let filePath = modelPath.appendingPathComponent(filename)
        var swiftText = introduction(for: filename)
        swiftText += emptyLine
    }

    func generateServices(services: [ProtoService]) {
        // create output directory
        _ = try? FileManager.default.createDirectory(at: servicePath, withIntermediateDirectories: true, attributes: nil)
        for service in services {
            generateService(service: service)
        }
        // for each service write
    }

    func generateService(service: ProtoService) {
        let filename = "\(service.fullName)+Generated.swift"
        let filePath = servicePath.appendingPathComponent(filename)
        var swiftText = introduction(for: filename)
        swiftText += emptyLine
        swiftText += "import Vapor\n"
        swiftText += "import GRPCVapor\n"
        swiftText += emptyLine
        swiftText += "extension \(service.fullName) {\n"
        swiftText += emptyLine
        swiftText += (indent(1) + "func handleMethod(methodName: String, vaporRequest: Request) -> AnyCallHandler? {\n")
        swiftText += (indent(2) + "switch methodName {\n")
        swiftText += service.methods.map(generateMethod).joined()
        swiftText += (indent(2) + "default:\n")
        swiftText += indent(3) + "return nil\n"
        swiftText += indent(2) + "}\n"
        swiftText += indent(1) + "}\n"
        swiftText += "}\n"
        do {
            try swiftText.write(to: filePath, atomically: false, encoding: .utf8)
        } catch let error {
            print("Failed: \(error)")
        }
    }

    func generateMethod(method: ProtoMethod) -> String {
        var swiftText = indent(2) + "case \"\(method.name.capitalizedFirstCharacter)\":\n"
        switch method.type {
        case .unaryCall, .clientStream:
            swiftText += indent(3) + "return try? \(method.type.callHandlerType)<_\(method.inputType.fullName), _\(method.outputType.fullName)>(vaporRequest: vaporRequest) { req in\n"
            swiftText += indent(4) + "return self.\(method.name)(\(method.parameterName): req)\n"
            swiftText += indent(3) + "}\n"
        case .serverStream, .bidirectionalStream:
            swiftText += indent(3) + "return try? \(method.type.callHandlerType)<_\(method.inputType.fullName), _\(method.outputType.fullName)>(vaporRequest: vaporRequest, procedureCall: self.\(method.name))\n"
        }
        return swiftText
    }

    func indent(_ count: Int) -> String {
        return String.init(repeating: "    ", count: count)
    }

    func introduction(for filename: String) -> String {
        let emptyLine = "//\n"
        let nameLine = "// \(filename)\n"
        let introductionText = "// This file was generated by the GRPC Middleware\n"

        return emptyLine + nameLine + emptyLine + emptyLine + introductionText + emptyLine
    }

    func generateModelExtension(for model: ProtoModel) {
        let extensionFile = FileWriter()
        extensionFile.println("import GRPCVapor")
        extensionFile.println()
        // extension _ protoname
        extensionFile.println("extension _\(model.fullName): GRPCMessage {")
        extensionFile.startIndent()
        extensionFile.println("typealias ModelType = \(model.fullName)")
        extensionFile.println()
        extensionFile.println("init(modelObject: \(model.fullName)) {")
        extensionFile.startIndent()
        model.attributes.forEach { generateMessageAttribute(attribute: $0, model: model, fileWriter: extensionFile) }
        extensionFile.endIndent()
        extensionFile.println("}")

        extensionFile.println()
        extensionFile.println("func toModel() -> \(model.fullName) {")
        extensionFile.startIndent()
        extensionFile.println("var object = \(model.fullName)()")
        model.attributes.forEach { generateModelAttribute(attribute: $0, fileWriter: extensionFile) }
        extensionFile.println("return object")
        extensionFile.endIndent()
        extensionFile.println("}")
        extensionFile.endIndent()
        extensionFile.println("}")

        let modelExtensionPath = outputPath.appendingPathComponent("\(model.fullName)+Generated.swift")

        do {
            try extensionFile.text.write(to: modelExtensionPath, atomically: false, encoding: .utf8)
        } catch let error {
            print("Failed: \(error)")
        }
    }

    func generateModelAttribute(attribute: ProtoAttribute, fileWriter: FileWriter) {
        switch attribute.type {
        case let .optional(optionalType):
            fileWriter.println("object.\(attribute.name) = \(attribute.protoOptionalName).flatMap { optional in")
            fileWriter.startIndent()
            fileWriter.println("if case let .\(attribute.name)(value) = optional {")
            fileWriter.printlnIndent("return \(optionalType)(value)")
            fileWriter.printlnIndent("} else {")
            fileWriter.printlnIndent("return nil")
            fileWriter.printlnIndent("}")
            fileWriter.endIndent()
            fileWriter.println("}")
        default:
            fileWriter.println("object.\(attribute.name) = \(attribute.name)")
        }
    }

    func generateMessageAttribute(attribute: ProtoAttribute, model: ProtoModel, fileWriter: FileWriter) {
        switch attribute.type {
        case let .optional(optionalType):
            fileWriter.printlnIndent("\(attribute.protoOptionalName) = modelObject.\(attribute.name).map { _\(model.fullName).OneOf_\(attribute.protoOptionalName.uppercased()).\(attribute.name)(\(optionalType.swiftString)($0)) } ?? _\(model.fullName).OneOf_\(attribute.protoOptionalName.uppercased()).no\(attribute.name.uppercased())(_Nil())")
        default:
            fileWriter.println("\(attribute.name) = modelObject.\(attribute.name)")
        }
    }
}

// Idee Quelle: https://www.hackingwithswift.com/example-code/strings/how-to-capitalize-the-first-letter-of-a-string
extension String {
    var capitalizedFirstCharacter: String {
        self.prefix(1).capitalized + self.dropFirst()
    }
}

class FileWriter {
    var text = ""
    let indent = "  "
    var indentionLevel = 0

    func println(_ line: String = "") {
        guard !line.isEmpty else {
            text += "\n"
            return
        }
        text += indent(indentionLevel) + line + "\n"
    }

    func printlnIndent(_ line: String) {
        text += indent(indentionLevel+1) + line + "\n"
    }

    func startIndent() {
        indentionLevel += 1
    }

    func endIndent() {
        guard indentionLevel > 0 else { return }
        indentionLevel -= 1
    }

    private func indent(_ count: Int) -> String {
        guard count > 0 else { return "" }
        return String.init(repeating: "    ", count: count)
    }
}
