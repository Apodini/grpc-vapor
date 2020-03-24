//
//  ProtoService.swift
//  
//
//  Created by Michael Schlicker on 17.02.20.
//

import Foundation

struct ProtoService {
    let fullName: String
    var methods: [ProtoMethod] = []

    var protoName: String {
        // Use underscore instead
        fullName.split(separator: ".")
            .map { String($0).capitalizedFirstCharacter }
            .joined()
    }

    init?(service: Service, knownModels: [ProtoModel]) {
        guard service.isService else { return nil }
        self.fullName = service.fullName
        self.methods = service.methods.values.compactMap { method in
            let inputTypes = knownModels.compactMap { $0.getModelType(typeName: method.inputType, knownModels: []) }
            let outputTypes = knownModels.compactMap { $0.getModelType(typeName: method.outputType, knownModels: []) }
            guard let inputType = inputTypes.first, let outputType = outputTypes.first else { return nil }
            return ProtoMethod(name: method.name,
                        parameterName: method.parameterName,
                        type: method.type,
                        inputType: inputType,
                        outputType: outputType)
        }
    }
}
