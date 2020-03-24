//
//  Analyzer.swift
//  
//
//  Created by Michael Schlicker on 20.01.20.
//

import Foundation
import CLIKit
import SourceKittenFramework

struct Analyzer {

    static func analyzeFiles(at paths: [Path]) -> AnalyzeResult {
        var result = AnalyzeResult()
        result.mergeResults(paths.compactMap(analyzeFile))
        return result
    }

    private static func analyzeFile(path: Path) -> AnalyzeResult? {
        let fileAnalyzer = FileAnaylzer(path: path)
        return fileAnalyzer.analyze()
    }
}

