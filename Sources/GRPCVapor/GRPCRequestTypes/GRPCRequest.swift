//
//  GRPCRequest.swift
//
//
//  Created by Michael Schlicker on 28.11.19.
//

import Vapor

/**
A `GRPCRequest` instance represents a unary gRPC request that provides the single incoming value and a generic `succeed` method to create a singe response future.
 It implements the `GRPCRequestType` that requires it to contain its Vapor `Request` and provides several shortcuts to several Vapor stack functionality.
 This is also a generic class which has type constrait for the `RequestModel` type which implements the `GRPCModel` protocol.
*/
public class GRPCRequest<RequestModel: GRPCModel>: GRPCRequestType {

    /// Single incoming `RequestModel` value which type is defined by the class constraint.
    public let message: RequestModel

    /// Vapor `Request` from which the gRPC request was instantiated. This reference is required by the `GRPCRequestType` protocol.
    public var vaporRequest: Request

    /**
    Initializes a `GRPCRequest` with the single incoming `RequestModel` and associated Vapor `Request`.
     This initializer stores both of these parameters as public attributes.

    - parameter message: Single incoming `RequestModel` value which type is defined by the class constraint.
    - parameter vaporRequest: Vapor `Request` instance of the incoming Vapor call.
    */
    init(message: RequestModel, vaporRequest: Request) {
        self.message = message
        self.vaporRequest = vaporRequest
    }

    /**
    Creates a succeeded future of a `GRPCModel` type which is usually the response type on the event loop of the `vaporRequest`.
     This is a generic function with a `ResponseModel` which implements the `GRPCModel` protocol as a type constraint.
     It acts as shortcut to the `succeed` method of the Vapors `Request`type.
    - parameter value: Single value of the `ResponseModel` that is used to succeed the created future.
    - returns: A succeeded future of the type `ResponseModel` on the `vaporRequest` event loop.
    */
    public func succeed<ResponseModel: GRPCModel>(value: ResponseModel) -> EventLoopFuture<ResponseModel> {
        return vaporRequest.eventLoop.makeSucceededFuture(value)
    }
}
