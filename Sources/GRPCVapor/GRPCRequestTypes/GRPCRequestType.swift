//
//  GRPCRequestType.swift
//  
//
//  Created by Michael Schlicker on 22.03.20.
//

import Vapor
import FluentKit
import Fluent

/**
`GRPCRequestType` is a protocol that is implemented by all gRPC request classes and requires attributes used by common default implementations.

 Currently the only required attribute is a reference to the used Vapor `Request` which is used to provide shortcuts for using the associated Fluent database and the request's `EventLoop`.
*/
public protocol GRPCRequestType {

    /// Vapor `Request` from which the gRPC request was instantiated.
    var vaporRequest: Request { get set }
}

public extension GRPCRequestType {

    /// `Database` associated with the requests Vapor `Request`.
    var db: Database {
        vaporRequest.db
    }

    /// `EventLoop` on which the Vapor `Request` runs.
    var eventLoop: EventLoop {
        vaporRequest.eventLoop
    }
}
