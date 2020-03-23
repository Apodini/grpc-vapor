//
//  File.swift
//  
//
//  Created by Michael Schlicker on 15.01.20.
//

import Vapor

public class ClientStreamingCallHandler<RequestMessage: GRPCMessage, ResponseMessage: GRPCMessage>: AnyCallHandler, RequestProcessable, ResponseProcessable {
    public var vaporRequest: Request

    public var response: EventLoopFuture<Response> { return promise.futureResult }

    private var promise: EventLoopPromise<Response>

    public var procedureCall: (GRPCClientStreamRequest<RequestMessage.ModelType>) -> EventLoopFuture<ResponseMessage.ModelType>

    public init(vaporRequest: Request, procedureCall: @escaping (GRPCClientStreamRequest<RequestMessage.ModelType>) -> EventLoopFuture<ResponseMessage.ModelType>) throws {
        self.vaporRequest = vaporRequest
        self.procedureCall = procedureCall

        self.promise = vaporRequest.eventLoop.makePromise(of: Response.self)

        var firstBuffer: ByteBuffer?

        var nextStr: EventLoopPromise<GRPCStream<RequestMessage.ModelType>> = vaporRequest.eventLoop.makePromise(of: GRPCStream<RequestMessage.ModelType>.self)
        let stream = GRPCStream<RequestMessage.ModelType>.start(nextStr.futureResult)
        let request = GRPCClientStreamRequest<RequestMessage.ModelType>.init(stream: stream, vaporRequest: vaporRequest)

        let responseMessage: EventLoopFuture<ResponseMessage.ModelType> = procedureCall(request)

        vaporRequest.body.drain { bodyStream in
            switch bodyStream {
            case let .buffer(buff):
                firstBuffer = buff
                guard let message = try? self.processRequest(buff) else {
                    return vaporRequest.eventLoop.makeSucceededFuture(())
                }
                let newNext = vaporRequest.eventLoop.makePromise(of: GRPCStream<RequestMessage.ModelType>.self)
                let nextStream = GRPCStream<RequestMessage.ModelType>.message(message, nextMessage: newNext.futureResult)
                nextStr.succeed(nextStream)
                nextStr = newNext
            case .end:
                nextStr.succeed(.end)
                responseMessage.whenSuccess { responseMessage in
                    let response = try! self.processResponse(responseMessage, buffer: firstBuffer!)
                    self.promise.succeed(response)
                }
            case let .error(error):
                return vaporRequest.eventLoop.makeFailedFuture(error)
            }
            return vaporRequest.eventLoop.makeSucceededFuture(())
        }
    }
}
