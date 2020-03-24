//
//  CodeAnalyzer.swift
//  
//
//  Created by Michael Schlicker on 21.03.20.
//

import Foundation

/// This protocol requires
struct CodeAnalyzer {
    static func analyze(inputPath: InputPath) -> GRPCApplication {
        let filePaths = FileCollector.collectSwiftFiles(inputPath: inputPath)
        let analyzeResults = filePaths.compactMap { path -> AnalyzeResult? in
            let fileAnalyzer = FileAnaylzer(path: path)
            return fileAnalyzer.analyze()
        }
        var analyzeResult = AnalyzeResult()
        analyzeResult.mergeResults(analyzeResults)
        return IntegrityChecker.createApplication(from: analyzeResult)
    }
}
