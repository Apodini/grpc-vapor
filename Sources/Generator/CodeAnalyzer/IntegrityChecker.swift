//
//  IntegrityChecker.swift
//  
//
//  Created by Michael Schlicker on 21.03.20.
//

import Foundation

struct IntegrityChecker {
    static func createApplication(from analyzeResult: AnalyzeResult) -> GRPCApplication {
        var application = GRPCApplication()
        let validModels = analyzeResult.models.values.filter { $0.implementsGRPCModel }
        application.models = Array(ProtoModelGenerator.generate(models: validModels.sorted()).values)
        application.models.forEach { $0.generateAttributes(knownModels: application.models) }
        application.services = analyzeResult.services.values.compactMap { ProtoService(service: $0, knownModels: application.models) }
        return application
    }
}
