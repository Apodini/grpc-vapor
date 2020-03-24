//
//  Model.swift
//  
//
//  Created by Michael Schlicker on 03.02.20.
//

import Foundation

/**
*/

struct Model {
    let fullName: String
    var implementsGRPCModel: Bool = false
    var attributes: [String: Attribute] = [:]

    init(fullName: String, isModel: Bool = false, attributes: [Attribute], attributeCases: [Attribute]) {
        self.fullName = fullName
        self.implementsGRPCModel = isModel
        self.addAttributes(attributes)
        self.addAttributeCases(attributeCases)
    }

    mutating func addAttributeCases(_ cases: [Attribute]) {
        guard attributes.values.compactMap({ $0.specifiedFieldNumber }).isEmpty else { return }
        let usedFieldNumbers = Set(cases.compactMap { $0.specifiedFieldNumber })
        var fieldNumberGenerator = FieldNumberGenerator(reservedFields: usedFieldNumbers)
        for `case` in cases {
            var attribute = attributes[`case`.name] ?? `case`
            attribute.name = `case`.name
            attribute.specifiedFieldNumber = `case`.specifiedFieldNumber ?? fieldNumberGenerator.next()
            attributes[`case`.name] = attribute
        }
    }

    mutating func addAttribute(_ newAttribute: Attribute) {
        let index = attributes[newAttribute.name]?.specifiedFieldNumber
        var attribute = newAttribute
        attribute.specifiedFieldNumber = index
        attributes[newAttribute.name] = attribute
    }

    mutating func addAttributes(_ attributes: [Attribute]) {
        for attribute in attributes {
            addAttribute(attribute)
        }
    }

    mutating func mergeModel(_ model: Model) {
        implementsGRPCModel = implementsGRPCModel || model.implementsGRPCModel
        for (attributeName, newAttribute) in model.attributes {
            let oldAttribute = attributes[attributeName]
            var newAttribute = newAttribute
            newAttribute.specifiedFieldNumber = newAttribute.specifiedFieldNumber ?? oldAttribute?.specifiedFieldNumber
            newAttribute.swiftType = newAttribute.swiftType ?? oldAttribute?.swiftType
            attributes[attributeName] = newAttribute
        }
    }
}

extension Model: Comparable {
    static func < (lhs: Model, rhs: Model) -> Bool {
        lhs.fullName < rhs.fullName
    }

    static func == (lhs: Model, rhs: Model) -> Bool {
        lhs.fullName == rhs.fullName
    }
}
