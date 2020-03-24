//
//  JSONStructure.swift
//  
//
//  Created by Michael Schlicker on 03.02.20.
//

import Foundation

struct Node: Codable {
    enum CodingKeys: String, CodingKey {
        case childNodes = "key.substructure"
        case length = "key.length"
        case name = "key.name"
        case inheritedTypes = "key.inheritedtypes"
        case kind = "key.kind"
        case type = "key.typename"
        case offset = "key.offset"
        case elements = "key.elements"
    }

    var childNodes: [Node]?
    var length: Int?
    var name: String?
    var inheritedTypes: [InheritedType]?
    var elements: [Node]?
    var kind: Kind?
    var type: String?
    var offset: Int?
}

enum Kind: String, Codable {
    case `class` = "source.lang.swift.decl.class"
    case `struct` = "source.lang.swift.decl.struct"
    case enumelement = "source.lang.swift.decl.enumelement"
    case method = "source.lang.swift.decl.function.method.instance"
    case `var` = "source.lang.swift.decl.var.instance"
    case parameter = "source.lang.swift.decl.var.parameter"
    case `extension` = "source.lang.swift.decl.extension"
    case `enum` = "source.lang.swift.decl.enum"
    case enumcase = "source.lang.swift.decl.enumcase"
    case initexpr = "source.lang.swift.structure.elem.init_expr"
    case other = "other"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = Kind(rawValue: string) ?? .other
    }
}
