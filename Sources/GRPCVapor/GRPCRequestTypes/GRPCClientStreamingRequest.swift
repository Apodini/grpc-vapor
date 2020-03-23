//
//  GRPCClientStreamRequest.swift
//  
//
//  Created by Michael Schlicker on 22.03.20.
//

import Vapor

/**
A `GRPCClientStream` instance represents a client-streaming gRPC request that provides a `forEach` method which takes a closure that gets called for each incoming message of the stream, a `collect` method that returns all incoming messages collected as an array, and a generic `succeed` method to create a singe response future.
 It implements the `GRPCRequestType` that requires it to contain its Vapor `Request` and provides several shortcuts to several Vapor stack functionality.
 This is also a generic class which has type constrait for the `RequestModel` type which implements the `GRPCModel` protocol.
*/
public class GRPCClientStreamRequest<RequestModel: GRPCModel>: GRPCRequestType {

    /// Incoming `GRPCStream`  which type is defined by the class constraint.
    private var messageStream: GRPCStream<RequestModel>

    /// Vapor `Request` from which the gRPC request was instantiated. This reference is required by the `GRPCRequestType` protocol.
    public var vaporRequest: Request

    /**
    Initializes a `GRPCStream` with the single incoming `RequestModel` and associated Vapor `Request`.
     This initializer stores both of these parameters as public attributes.

    - parameter messageStream: Incoming `GRPCStream`  which type is defined by the class constraint.
    - parameter vaporRequest: Vapor `Request` instance of the incoming Vapor call.
    */
    init(stream: GRPCStream<RequestModel>, vaporRequest: Request) {
        self.vaporRequest = vaporRequest
        self.messageStream = stream
    }

    /**
    Handles incoming messages from the `messageStream` by calling the passed closure for each of these messages.
     It calls the closure for the next message as soon as the next message arrived.
    - parameter onNext: A closure that gets a single `RequestModel` value to handle from the stream and returns `Void`
    - returns: A succeeded future of the type `Void` that succeeds when the stream has ended and the `forEach` method has been called for every message.
    */
    public func forEach(onNext: @escaping ((RequestModel) -> Void)) -> EventLoopFuture<Void> {
        switch messageStream {
        case let .start(firstMessage):
            return firstMessage.flatMap { firstMessageStream in
                self.messageStream = firstMessageStream
                return self.forEach(onNext: onNext)
            }
        case let .message(message, nextMessage: nextMessage):
            onNext(message)
            return nextMessage.flatMap { nextMessageStream in
                self.messageStream = nextMessageStream
                return self.forEach(onNext: onNext)
            }
        case .end:
            return vaporRequest.eventLoop.makeSucceededFuture(())
        }
    }

    /**
    Collects incoming messages from the `messageStream`and returns a future with an array of the collected `RequestModel`s.
    - returns: A succeeded future of the type `[RequestModel]` that succeeds with an array of every incoming messages once the stream has ended.
    */
    public func collect() -> EventLoopFuture<[RequestModel]> {
        var collectedMessages: [RequestModel] = []
        return forEach(onNext: { message in collectedMessages.append(message)})
            .map { _ in collectedMessages }
    }

    /**
    Creates a succeeded future of a `GRPCModel` type which is usually the response type on the event loop of the `vaporRequest`.
     This is a generic function with a `ResponseModel` which implements the `GRPCModel` protocol as a type constraint.
     It acts as shortcut to the `succeed` method of the Vapors `Request`type.
    - parameter value: Single value of the `ResponseModel` that is used to succeed the created future.
    - returns: A succeeded future of the type `ResponseModel` on the `vaporRequest` event loop.
    */
    public func succeed<ResponseModel>(value: ResponseModel) -> EventLoopFuture<ResponseModel> {
        return vaporRequest.eventLoop.makeSucceededFuture(value)
    }
}
