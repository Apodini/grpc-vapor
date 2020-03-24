//
//  Service.swift
//  
//
//  Created by Michael Schlicker on 03.02.20.
//

import Foundation

struct Service {

    let fullName: String
    var isService: Bool
    var methods: [String: Method] = [:]

    init(fullName: String, isService: Bool = false, methods: [Method]) {
        self.fullName = fullName
        self.isService = isService
        self.addMethods(methods)
    }

    mutating private func addMethod(_ method: Method) {
        methods[method.name] = method
    }

    mutating private func addMethods(_ methods: [Method]) {
        for method in methods {
            addMethod(method)
        }
    }

    mutating func mergeService(_ service: Service) {
        isService = isService || service.isService
        for (methodName, method) in service.methods {
            guard methods[methodName] == nil else {
                print("Error")
                continue
            }
            addMethod(method)
        }
    }
}
