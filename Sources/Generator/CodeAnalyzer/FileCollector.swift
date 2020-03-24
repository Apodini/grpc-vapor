//
//  FileCollector.swift
//  
//
//  Created by Michael Schlicker on 14.03.20.
//

import CLIKit

struct FileCollector {

    static func collectSwiftFiles(inputPath: InputPath) -> [Path] {
        let filePaths: [Path]
        switch inputPath {
        case let .swiftFile(swiftPath):
            filePaths = [swiftPath]
        case let .directory(dirPath):
            filePaths = getAllFilePaths(in: dirPath)
        case let .package(packagePath):
            filePaths = getAllFilePaths(in: packagePath.deletingLastComponent.appendingComponent(""))
        case let .project(projectPath):
            filePaths = getAllFilePaths(in: projectPath.deletingLastComponent)
        case .noPath:
            return []
        }
        return filePaths.filter { $0.extension == "swift" }
    }

    private static func getAllFilePaths(in directory: Path) -> [Path] {
        let filePaths = try? directory.contentsOfDirectory(fullPaths: true).filter { $0.isDirectory }
            .reduce((try? directory.contentsOfDirectory(fullPaths: true).filter({ $0.isFile })) ?? []) { paths, subdirectory in
                let subDirectoryFilePaths = getAllFilePaths(in: subdirectory)
                return paths + subDirectoryFilePaths
            }
        return filePaths ?? []
    }
}
