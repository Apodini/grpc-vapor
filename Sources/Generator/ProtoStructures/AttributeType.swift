//
//  AttributeType.swift
//  
//
//  Created by Michael Schlicker on 03.02.20.
//

import Foundation

indirect enum AttributeType {
    case scalarType(ValueType)
    case custom(ProtoModel)
    case array(Self)
    case dictionary(Self, Self)
    case optional(Self)

    private init?(keyType: String) {
        guard keyType.components(separatedBy: ["[","<",">",",",":"]).count == 1,
            let valueType = ValueType(typeName: keyType),
            ![.bytes, .float, .double].contains(valueType) else { return nil }
        self = .scalarType(valueType)
    }

    private init?(subtypeName: String, context: CustomTypeContext) {
        guard subtypeName.components(separatedBy: ["[","<",">",",",":"]).count == 1 else { return nil }
        if let valueType = ValueType(typeName: subtypeName) {
            self = .scalarType(valueType)
        } else if let modelType = context.searchContext.getModelType(typeName: subtypeName, knownModels: context.knownModels) {
            self = .custom(modelType)
        } else {
            return nil
        }
    }

    init?(typeName: String, context: CustomTypeContext) {
        let typeName = typeName.removeSpaces()
        guard !typeName.isEmpty else { return nil }
        guard typeName.last != "?" && !typeName.starts(with: "Optional<") else {
            var subtypeName = typeName.dropLast()
            if typeName.starts(with: "Optional<") {
                subtypeName = subtypeName.dropFirst("Optional<".count)
            }
            guard let subtype = AttributeType(subtypeName: String(subtypeName), context: context) else { return nil }
            self = .optional(subtype)
            return
        }
//        let dictionaryParts = typeName.split(whereSeparator: { $0 == "," || $0 == ":" })
//        guard dictionaryParts.count != 2, !typeName.starts(with: "Dictionary<"), typeName.first != "[" else {
//            let keyString: String
//            let valueString = String(dictionaryParts[1].dropLast())
//            if typeName.starts(with: "Dictionary<") {
//                keyString = String(dictionaryParts[0].dropLast("Dictionary<".count))
//            } else {
//                keyString = String(dictionaryParts[0].dropFirst())
//            }
//            guard let keyType = AttributeType(keyType: keyString),
//                let valueType = AttributeType(subtypeName: valueString, context: context) else { return nil }
//            self = .dictionary(keyType, valueType)
//            return
//        }
        guard typeName.first != "[" && !typeName.starts(with: "Array<") else {
            var subtypeName = typeName.dropLast()
            if typeName.starts(with: "Array<") {
                subtypeName = subtypeName.dropFirst("Array<".count)
            } else {
                subtypeName = subtypeName.dropFirst()
            }
            guard let subtype = AttributeType(subtypeName: String(subtypeName), context: context) else { return nil }
            self = .array(subtype)
            return
        }
        if let valueType = ValueType(typeName: typeName) {
            self = .scalarType(valueType)
        } else if let modelType = context.searchContext.getModelType(typeName: typeName, knownModels: context.knownModels) {
            self = .custom(modelType)
        } else {
            return nil
        }
    }

    var protoString: String {
        switch self {
        case let .scalarType(valueType):
            switch valueType {
            case .int:
                return "int64"
            case .uuid:
                return "string"
            default:
                return valueType.rawValue
            }
        case let .custom(modelType):
            return modelType.protoSuffixName
        case let .array(attributeType):
            return "repeated \(attributeType.protoString)"
        case let .optional(attributeType):
            return attributeType.protoString
        case let .dictionary(keyType, valueType):
            return "map<\(keyType.protoString), \(valueType.protoString)>"
        }
    }

    var swiftString: String {
        switch self {
        case let .scalarType(valueType):
            return valueType.swiftType
        case let .custom(modelType):
            return modelType.fullName
        case let .array(attributeType):
            return "[\(attributeType)]"
        case let .optional(attributeType):
            return attributeType.swiftString + "?"
        case let .dictionary(keyType, valueType):
            return "[\(keyType.swiftString): \(valueType.swiftString)]"
        }
    }

}

protocol CustomTypeSearchable {
    func getModelType(typeName: String, knownModels: [ProtoModel]) -> ProtoModel?
}
