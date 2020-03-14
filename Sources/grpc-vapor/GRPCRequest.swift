//
//  GRPCRequest.swift
//  Run
//
//  Created by Michael Schlicker on 28.11.19.
//

import Foundation
import FluentKit
import NIO
import Vapor
import GRPC
import FluentSQL
import Fluent

public class GRPCRequest<T: GRPCModel>: GRPCRequestType {
    public var vaporRequest: Request
    public var message: T

    init(message: T, vaporRequest: Request) {
        self.message = message
        self.vaporRequest = vaporRequest
    }

    public func succeed<ResponseModel: GRPCModel>(value: ResponseModel) -> EventLoopFuture<ResponseModel> {
        return vaporRequest.eventLoop.makeSucceededFuture(value)
    }
}

public extension GRPCRequestType {
    var db: Database {
        vaporRequest.db
    }
}

public class GRPCClientStreamRequest<RequestType: GRPCModel>: GRPCRequestType {
    public var vaporRequest: Request
    private var messageStream: GRPCStream<RequestType>
    init(stream: GRPCStream<RequestType>, vaporRequest: Request) {
        self.vaporRequest = vaporRequest
        self.messageStream = stream
    }

    public func forEach(onNext: @escaping ((RequestType) -> Void)) -> EventLoopFuture<Void> {
        switch messageStream {
        case let .message(message, nextMessage: nextMessage):
            onNext(message)
            return nextMessage.flatMap { nextM in
                self.messageStream = nextM
                return self.forEach(onNext: onNext)
            }
        default:
            return vaporRequest.eventLoop.makeSucceededFuture(())
        }
    }

    public func succeed<ResponseModel>(value: ResponseModel) -> EventLoopFuture<ResponseModel> {
        return vaporRequest.eventLoop.makeSucceededFuture(value)
    }
}

public protocol GRPCRequestType {
    var vaporRequest: Request { get set }
}

public enum GRPCStream<T: GRPCModel> {
    case start(EventLoopFuture<GRPCStream<T>>)
    case message(T, nextMessage: EventLoopFuture<GRPCStream<T>>)
    case end
}

public class GRPCServerStreamRequest<RequestType: GRPCModel, ResponseType: GRPCModel> {
    var responseStream: GRPCStream<ResponseType>
    var next: EventLoopPromise<GRPCStream<ResponseType>>
    public var vaporRequest: Request
    public var message: RequestType

    init(message: RequestType, vaporRequest: Request) {
        self.vaporRequest = vaporRequest
        self.message = message

        next = vaporRequest.eventLoop.makePromise(of: GRPCStream<ResponseType>.self)
        responseStream = .start(next.futureResult)
    }

    public func sendResponse(message: ResponseType) {
        let newPromise = vaporRequest.eventLoop.makePromise(of: GRPCStream<ResponseType>.self)
        next.succeed(GRPCStream<ResponseType>.message(message,
                                                      nextMessage: newPromise.futureResult))
        next = newPromise
    }

    public func sendEnd() {
        next.succeed(.end)
    }
}

public class GRPCStreamRequest<RequestType: GRPCModel, ResponseType: GRPCModel> {
    var messageStream: GRPCStream<RequestType>
    var responseStream: GRPCStream<ResponseType>
    var next: EventLoopPromise<GRPCStream<ResponseType>>
    public var vaporRequest: Request

    init(messageStream: GRPCStream<RequestType>, vaporRequest: Request) {
        self.vaporRequest = vaporRequest
        self.messageStream = messageStream

        next = vaporRequest.eventLoop.makePromise(of: GRPCStream<ResponseType>.self)
        responseStream = .start(next.futureResult)
    }

    public func forEach(onNext: @escaping ((RequestType) -> Void)) -> EventLoopFuture<Void> {
        switch messageStream {
        case let .message(message, nextMessage: nextMessage):
            onNext(message)
            return nextMessage.flatMap { nextM in
                self.messageStream = nextM
                return self.forEach(onNext: onNext)
            }
        default:
            return vaporRequest.eventLoop.makeSucceededFuture(())
        }
    }

    public func respondforEach(onNext: @escaping ((RequestType) -> ResponseType)) {
        switch messageStream {
        case let .start(firstMessage):
            firstMessage.map { firstM in
                self.messageStream = firstM
                self.respondforEach(onNext: onNext)
            }
        case let .message(message, nextMessage: nextMessage):
            let response = onNext(message)
            sendResponse(message: response)
            nextMessage.map { nextM in
                self.messageStream = nextM
                self.respondforEach(onNext: onNext)
            }
        case .end:
            self.sendEnd()
        }
    }

    public func sendResponse(message: ResponseType) {
        let newPromise = vaporRequest.eventLoop.makePromise(of: GRPCStream<ResponseType>.self)
        next.succeed(GRPCStream<ResponseType>.message(message,
                                                      nextMessage: newPromise.futureResult))
        next = newPromise
    }

    public func sendEnd() {
        next.succeed(.end)
    }
}
