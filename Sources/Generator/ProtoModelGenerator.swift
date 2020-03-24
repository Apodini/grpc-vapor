//
//  File.swift
//  
//
//  Created by Michael Schlicker on 03.02.20.
//

import Foundation

struct ProtoModelGenerator {
    static func generate(models: [Model]) -> [String: ProtoModel] {
        return models.reduce(into: [String: ProtoModel]()) { acc, model in
            let parts = model.fullName.split(separator: ".")
            let protoModel = insertModel(parent: nil, knownModels: acc, model: model, remainingSuffixes: parts)
            acc[protoModel.model.fullName] = protoModel
        }
    }

    private static func parentModel(knownModels: [String: ProtoModel], remainingSuffixes: [String.SubSequence]) -> ProtoModel? {
        guard remainingSuffixes.count >= 1 else { return nil }
        for index in 1...remainingSuffixes.count {
            let prefixName = remainingSuffixes.prefix(index).joined(separator: ".")
            if let proto = knownModels[prefixName] {
                return proto
            }
        }
        return nil
    }

    private static func insertModel(parent: ProtoModel?, knownModels: [String: ProtoModel], model: Model, remainingSuffixes: [String.SubSequence]) -> ProtoModel {
        guard let newParent = parentModel(knownModels: knownModels, remainingSuffixes: remainingSuffixes) else {
            return ProtoModel(model, suffix: remainingSuffixes, parent: parent)
        }
        let prefixCount = newParent.model.fullName.split(separator: ".").count
        let suffixes = Array(model.fullName.split(separator: ".").dropFirst(prefixCount))
        let this = insertModel(parent: newParent, knownModels: newParent.subModels, model: model, remainingSuffixes: suffixes)
        newParent.subModels[this.model.fullName.split(separator: ".").dropFirst(prefixCount).joined(separator: ".")] = this
        return newParent
    }
}
