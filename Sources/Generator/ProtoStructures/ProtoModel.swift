//
//  ProtoModel.swift
//  
//
//  Created by Michael Schlicker on 03.02.20.
//

import Foundation

class ProtoModel {
    var model: Model
    var fullName: String
    var suffixName: String
    var protoSuffixName: String
    var protoFullName: String { (parent?.protoFullName ?? "") + protoSuffixName }
    weak var parent: ProtoModel?
    var attributes: [ProtoAttribute] = []
    var subModels: [String: ProtoModel]

    init(_ model: Model, suffix: [String.SubSequence], parent: ProtoModel?, subModels: [String: ProtoModel] = [:]) {
        self.model = model
        self.fullName = model.fullName
        self.suffixName = suffix.joined(separator: ".")
        self.protoSuffixName = suffix.joined(separator: "_")
        self.parent = parent
        self.subModels = subModels
    }

    func generateAttributes(knownModels: [ProtoModel]) {
        let filteredAttributes: [Attribute]
//        if let cases = model.attributeCases {
//            sortedAttr = cases.compactMap { attributeName in
//                return model.attributes[attributeName]
//            }
//        } else {
//            sortedAttr = Array(model.attributes.values)
//        }
        let attributesWithNumbers = model.attributes.values.filter({ $0.specifiedFieldNumber != nil })
        if attributesWithNumbers.count > 0 {
            filteredAttributes = attributesWithNumbers
        } else {
            filteredAttributes = Array(model.attributes.values)
        }
        var fieldNumberGenerator = FieldNumberGenerator()

        // Side Effects
        let context = CustomTypeContext(searchContext: self, knownModels: knownModels)
        attributes = filteredAttributes.compactMap {
            guard let swiftType = $0.swiftType,
                let type = AttributeType(typeName: swiftType, context: context) else { return nil }
            return ProtoAttribute(name: $0.name, fieldNumber: fieldNumberGenerator.next(), type: type)
        }
    }
}

typealias CustomTypeContext = (searchContext: CustomTypeSearchable, knownModels: [ProtoModel])

extension ProtoModel: CustomTypeSearchable {
    func getModelType(typeName: String, knownModels: [ProtoModel]) -> ProtoModel? {
        if fullName.hasSuffix(typeName) { // not enough
            return self
        }
        // first search subtypes
        if let subType = subModels.values.compactMap({ $0.getModelType(typeName: typeName, startPrefix: fullName) }).first {
            return subType
        }
        // then parent
        if let parentType = parent?.getModelType(typeName: typeName, ignoring: self) {
            return parentType
        }

        let rootParent = self.rootParent()
        // then others
        return knownModels.filter({ $0 != rootParent}).compactMap { $0.getModelType(typeName: typeName, startPrefix: "")}.first
    }

    private func rootParent() -> ProtoModel {
        return parent?.rootParent() ?? self
    }

    private func getModelType(typeName: String, startPrefix: String) -> ProtoModel? {
        if fullName.starts(with: startPrefix), fullName.hasSuffix(typeName) {
            return self
        }
        return subModels.values.compactMap({ $0.getModelType(typeName: typeName, startPrefix: fullName) }).first
    }

    private func getModelType(typeName: String, ignoring: ProtoModel) -> ProtoModel? {
        if fullName.hasSuffix(typeName) {
            return self
        }
        if let subType = subModels.values.filter({ $0 == ignoring }).compactMap({ $0.getModelType(typeName: typeName, startPrefix: fullName)}).first {
            return subType
        }
        return parent?.getModelType(typeName: typeName, ignoring: self)
    }
}

extension ProtoModel: Equatable {
    static func == (lhs: ProtoModel, rhs: ProtoModel) -> Bool {
        lhs.fullName == rhs.fullName
    }
}

struct FieldNumberGenerator {
    var usedFieldNumbers = Set<Int>()
    var reservedFieldNumbers: Set<Int>
    var lastUsedNumber: Int = 0

    init(reservedFields: Set<Int> = Set<Int>()) {
        reservedFieldNumbers = reservedFields
    }

    mutating func next() -> Int {
        let next = lastUsedNumber + 1
        guard !reservedFieldNumbers.contains(next) else {
            lastUsedNumber += 1
            return self.next()
        }
        guard next < 19_000 || next > 19_999 else {
            lastUsedNumber = 19_999
            return self.next()
        }
        lastUsedNumber = next
        usedFieldNumbers.insert(next)
        return next
    }

    mutating func generateFieldNumbers(k: Int, reservedFieldNumbers: Set<Int> = Set<Int>()) -> [Int] {
        self.reservedFieldNumbers = reservedFieldNumbers
        return (1...k).map { _ in next() }
    }
}
