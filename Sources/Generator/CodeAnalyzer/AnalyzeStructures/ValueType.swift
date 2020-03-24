//
//  ValueType.swift
//  
//
//  Created by Michael Schlicker on 03.02.20.
//

import Foundation

enum ValueType: String {
    case double
    case float
    case int32
    case int64
    case int
    case uint64
    case uint32
    case sint32
    case sint64
    case fixed32
    case fixed64
    case sfixed32
    case sfixed64
    case bool
    case string
    case bytes
    case uuid

    init?(typeName: String) {
        switch typeName {
        case "Int32":
            self = .int32
        case "UInt32":
            self = .uint32
        case "Int":
            self = .int
        case "Int64":
            self = .int64
        case "UInt64":
            self = .uint64
        case "Double":
            self = .double
        case "Float":
            self = .float
        case "Bool":
            self = .bool
        case "String":
            self = .string
        case "Data":
            self = .bytes
        case "UUID":
            self = .uuid
        default:
            return nil
        }
    }

    var swiftType: String {
        switch self {
        case .bool:
            return "Bool"
        case .bytes:
            return "Data"
        case .double:
            return "Double"
        case .fixed32:
            return "Int32"
        case .fixed64:
            return "Int"
        case .float:
            return "Float"
        case .int32:
            return "Int32"
        case .int64:
            return "Int64"
        case .int:
            return "Int"
        case .sfixed32:
            return "Int32"
        case .sfixed64:
            return "Int"
        case .sint32:
            return "Int32"
        case .sint64:
            return "Int"
        case .string:
            return "String"
        case .uint32:
            return "UInt32"
        case .uint64:
            return "UInt64"
        case .uuid:
            return "UUID"
        }
    }
}
