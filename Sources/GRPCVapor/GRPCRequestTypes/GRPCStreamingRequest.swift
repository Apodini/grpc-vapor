//
//  GRPCStreamRequest.swift
//  
//
//  Created by Michael Schlicker on 22.03.20.
//

import Vapor

public class GRPCStreamRequest<RequestModel: GRPCModel, ResponseModel: GRPCModel>: GRPCRequestType {

    // MARK: Public Attributes

    /// Vapor `Request` from which the gRPC request was instantiated. This reference is required by the `GRPCRequestType` protocol.
    public var vaporRequest: Request

    // MARK: Internal Attributes

    /// Incoming `GRPCStream`  which type is defined by the class constraint.
    var messageStream: GRPCStream<RequestModel>

    /// Outgoing `GRPCStream`  which type is defined by the `ResponseModel` class constraint.
    var responseStream: GRPCStream<ResponseModel>

    /// Promise of the next `GRPCStream` message that is used to refernce the next message from the current one.
    var next: EventLoopPromise<GRPCStream<ResponseModel>>


    init(messageStream: GRPCStream<RequestModel>, vaporRequest: Request) {
        self.vaporRequest = vaporRequest
        self.messageStream = messageStream

        next = vaporRequest.eventLoop.makePromise(of: GRPCStream<ResponseModel>.self)
        responseStream = .start(next.futureResult)
    }

    // MARK: Client Streaming Methods

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

    // MARK: Server Streaming Methods

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

    
    public func sendEnd() {
        next.succeed(.end)
    }

    // MARK: Client Streaming Methods

    public func respondforEach(onNext: @escaping ((RequestModel) -> ResponseModel)) {
        switch messageStream {
        case let .start(firstMessageFuture):
            firstMessageFuture.whenComplete { firstResult in
                switch firstResult {
                case let .success(firstMessage):
                    self.messageStream = firstMessage
                    self.respondforEach(onNext: onNext)
                case .failure:
                    self.messageStream = .end
                }
            }
        case let .message(message, nextMessage: nextMessageFuture):
            let response = onNext(message)
            sendResponse(message: response)
            nextMessageFuture.whenComplete { nextResult in
                switch nextResult {
                case let .success(nextMessage):
                    self.messageStream = nextMessage
                    self.respondforEach(onNext: onNext)
                case .failure:
                    self.messageStream = .end
                }
            }
        case .end:
            self.sendEnd()
        }
    }
}
