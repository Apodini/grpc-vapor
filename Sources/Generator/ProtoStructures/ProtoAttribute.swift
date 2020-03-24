//
//  File.swift
//  
//
//  Created by Michael Schlicker on 17.02.20.
//

import Foundation

struct ProtoAttribute {
    var name: String
    var fieldNumber: Int
    var type: AttributeType
    var protoOptionalName: String { name + "_optional" }
}

extension ProtoAttribute: Comparable {
    static func < (lhs: ProtoAttribute, rhs: ProtoAttribute) -> Bool {
        return lhs.fieldNumber < rhs.fieldNumber
    }

    static func == (lhs: ProtoAttribute, rhs: ProtoAttribute) -> Bool {
        lhs.fieldNumber == rhs.fieldNumber
    }
}
