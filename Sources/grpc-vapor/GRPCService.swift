//
//  GRPCService.swift
//  
//
//  Created by Michael Schlicker on 13.12.19.
//

import Foundation
import NIO
import Vapor

public protocol GRPCService {
    var serviceName: String { get }

    func handleMethod(methodName: String, vaporRequest: Request) -> AnyCallHandler?
}

public extension GRPCService {
    var serviceName: String {
        let desc = String(describing: self)
        let components = desc.components(separatedBy: ".")
        return components.last ?? desc
    }

//    Should be a standard implementation to avoid compiler errors before code generation but it doesn't work yet
    func handleMethod(methodName: String, vaporRequest: Request) -> AnyCallHandler? {
        return nil
    }
}
