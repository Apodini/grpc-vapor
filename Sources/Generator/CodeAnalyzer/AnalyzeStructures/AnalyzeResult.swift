//
//  GRPCApplication.swift
//  
//
//  Created by Michael Schlicker on 03.02.20.
//

import Foundation

struct AnalyzeResult {
    var services: [String: Service] = [:]
    var models: [String: Model] = [:]

    init() { }

    mutating func mergeResults(_ applications: [AnalyzeResult]) {
        for application in applications {
            mergeResults(application)
        }
    }

    mutating func mergeResults(_ application: AnalyzeResult) {
        mergeServices(application.services)
        mergeModels(application.models)
    }

    mutating func mergeServices(_ services: [String: Service]) {
        for (serviceName, service) in services {
            if self.services[serviceName] != nil {
                self.services[serviceName]?.mergeService(service)
            } else {
                self.services[serviceName] = service
            }
        }
    }

    mutating func mergeModels(_ models: [String: Model]) {
        for (modelName, model) in models {
            if self.models[modelName] != nil {
                self.models[modelName]?.mergeModel(model)
            } else {
                self.models[modelName] = model
            }
        }
    }

}


