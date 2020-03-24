//
//  GRPCServerStreamRequest.swift
//  
//
//  Created by Michael Schlicker on 22.03.20.
//

import Vapor

/**
A `GRPCServerStreamRequest` instance represents a server-streaming gRPC request that provides the single incoming value and `sendResponse` and `sendEnd` methods to send a multiple responses.
 It implements the `GRPCRequestType` that requires it to contain its Vapor `Request` and provides several shortcuts to several Vapor stack functionality.
 This is also a generic class which has two type constraits that implement the `GRPCModel` protocol.
 One constraint for the `RequestModel` type and one constraint for the `ResponseModel`.
*/

public class GRPCServerStreamRequest<RequestModel: GRPCModel, ResponseModel: GRPCModel>: GRPCRequestType {

    // MARK: Public Attributes

    /// Single incoming `RequestModel` value which type is defined by the class constraint.
    public let message: RequestModel

    /// Vapor `Request` from which the gRPC request was instantiated. This reference is required by the `GRPCRequestType` protocol.
    public var vaporRequest: Request

    // MARK: Internal Attributes

    /// Outgoing `GRPCStream`  which type is defined by the `ResponseModel` class constraint.
    var responseStream: GRPCStream<ResponseModel>

    /// Promise of the next `GRPCStream` message that is used to refernce the next message from the current one.
    var next: EventLoopPromise<GRPCStream<ResponseModel>>

    // MARK: Initializers

    /**
    Initializes a `GRPCServerStreamRequest` with the single incoming `RequestModel` and associated Vapor `Request`.
     This initializer stores both of these parameters as public attributes.
     It also creates a promise for the first message and a start stream message with the first message promise.

    - parameter message: Single incoming `RequestModel` value which type is defined by the class constraint.
    - parameter vaporRequest: Vapor `Request` instance of the incoming Vapor call.
    */

    init(message: RequestModel, vaporRequest: Request) {
        self.vaporRequest = vaporRequest
        self.message = message

        next = vaporRequest.eventLoop.makePromise(of: GRPCStream<ResponseModel>.self)
        responseStream = .start(next.futureResult)
    }

    // MARK: Public Methods

    /**
    Sends a response of type `ResponseModel` by succeeding the promise of the previous message with the response message value and a promise for the next stream message.

    - parameter message: Single outgoing `ResponseModel` object which will be sent as a response.
    */

    public func sendResponse(message: ResponseModel) {
        let newPromise = vaporRequest.eventLoop.makePromise(of: GRPCStream<ResponseModel>.self)
        next.succeed(GRPCStream<ResponseModel>.message(message,
                                                      nextMessage: newPromise.futureResult))
        next = newPromise
    }

    ///Ends the response stream by succeeding the promise of the previous message with a stream end message.
    public func sendEnd() {
        next.succeed(.end)
    }
}
