//
//  File.swift
//  
//
//  Created by Michael Schlicker on 28.01.20.
//

import CLIKit

class GeneratorCommands: Commands {
    let description = "Manages the state of the GraphQL Integrations in your project"

    let codegen = CodegenCommand()
}
