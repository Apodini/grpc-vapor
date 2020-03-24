//
//  Attribute.swift
//  
//
//  Created by Michael Schlicker on 03.02.20.
//

import Foundation

struct Attribute {
    var name: String
    var specifiedFieldNumber: Int?
    var swiftType: String?

    init(name: String = "", id: Int? = nil, swiftType: String? = nil) {
        self.name = name
        self.specifiedFieldNumber = id
        self.swiftType = swiftType
    }
}
