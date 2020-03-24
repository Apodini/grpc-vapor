//
//  CodeGenerator.swift
//  
//
//  Created by Michael Schlicker on 21.03.20.
//

import Foundation

struct CodeGenerator {
    var outputPath: OutputPath

    func generate(_ application: GRPCApplication) {
        let generator = Generator(outputPath: outputPath.path.url)
        generator.generate(from: application)
    }
}
