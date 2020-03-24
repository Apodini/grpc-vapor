//
//  InheritedType.swift
//  
//
//  Created by Michael Schlicker on 03.02.20.
//

import Foundation

struct InheritedType: Codable {
    enum CodingKeys: String, CodingKey {
        case name = "key.name"
    }
    var name: String
}
