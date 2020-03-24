//
//  CodegenCommand.swift
//  
//
//  Created by Michael Schlicker on 28.01.20.
//

import CLIKit
import Dispatch

class CodegenCommand: Command {

    @CommandOption(default: InputPath.noPath, description: "path")
    var inputPath: InputPath

    @CommandOption(default: OutputPath.default, description: "path")
    var outputPath: OutputPath

    func run() throws {
        let application = CodeAnalyzer.analyze(inputPath: inputPath)
        let codeGenerator = CodeGenerator(outputPath: outputPath)
        codeGenerator.generate(application)
    }

    var description: String = "Bla"
}

enum InputPath: CommandArgumentValue {
    var description: String { return "specifies path of directory, xcode project or single swift file" }

    init(argumentValue: String) throws {
        let pathString = argumentValue != "" ? argumentValue : nil
        let path = pathString.map { Path($0) } ?? Path.currentDirectory
        guard path.exists else { throw ArgumentError.inputPathNotExisting(path: argumentValue) }
        guard path.isReadable else { throw ArgumentError.inputPathNotReadable(path: argumentValue) }

        if path.isFile {
            guard path.extension == "swift" else { throw ArgumentError.inputInvalidFileType(type: path.extension) }
            self = .swiftFile(path)
        } else if path.isDirectory {
            if path.extension == "xcodeproj" {
                self = .project(path)
            } else {
                self = .directory(path)
            }
        } else {
            throw ArgumentError.inputPathUnknownFormat
        }
    }

    static let `default`: InputPath = .directory(Path.currentDirectory)

    case noPath
    case project(Path)
    case directory(Path)
    case swiftFile (Path)
    case package(Path)
}


struct OutputPath: CommandArgumentValue {
    var description: String { return "" }

    // TODO: throws
    static let `default`: OutputPath = OutputPath()

    init(argumentValue: String) {
        let pathString = argumentValue != "" ? argumentValue : nil
        let path = pathString.map { Path($0) } ?? Path.currentDirectory
//        guard path.exists else { throw ArgumentError.outputPathNotExisting(path: argumentValue) }
//        guard path.isWritable else { throw ArgumentError.outputPathNotWriteable(path: argumentValue) }
        self.path = path
    }

    init() {
        path = Path.currentDirectory
    }

    var path: Path
}

enum ArgumentError: Error {
    case inputPathNotExisting(path: String)
    case inputPathNotReadable(path: String)
    case inputInvalidFileType(type: String)
    case inputPathUnknownFormat
    case outputPathNotExisting(path: String)
    case outputPathNotWriteable(path: String)
}
