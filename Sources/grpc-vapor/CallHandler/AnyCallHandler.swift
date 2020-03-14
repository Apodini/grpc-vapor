//
//  AnyCallHandler.swift
//  
//
//  Created by Michael Schlicker on 15.01.20.
//

import Vapor

public protocol AnyCallHandler {
    var vaporRequest: Request { get set }
    var errorResponse: Response { get }
    var response: EventLoopFuture<Response> { get }
}


extension AnyCallHandler {
    public var errorResponse: Response {
        Response.init(status: .ok,
                      version: .init(major: 2, minor: 0),
                      headers: vaporRequest.headers,
                      body: Response.Body.init())
    }
}
