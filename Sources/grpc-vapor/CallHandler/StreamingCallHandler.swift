//
//  File.swift
//  
//
//  Created by Michael Schlicker on 15.01.20.
//

import Vapor

public class StreamingCallHandler<RequestMessage: GRPCMessage, ResponseMessage: GRPCMessage>: AnyCallHandler, RequestProcessable, StreamingResponseProcessable {

    public var vaporRequest: Request

    public var response: EventLoopFuture<Response> { return promise.futureResult }

    private var promise: EventLoopPromise<Response>
    private var request: GRPCStreamRequest<RequestMessage.ModelType, ResponseMessage.ModelType>?

    var eventFactory: ((GRPCStreamRequest<RequestMessage.ModelType, ResponseMessage.ModelType>) -> Void)
    var handler: StreamingCallHandler<RequestMessage, ResponseMessage>?


    public init(vaporRequest: Request,
                eventFactory: @escaping ((GRPCStreamRequest<RequestMessage.ModelType, ResponseMessage.ModelType>) -> Void)) throws {
        self.vaporRequest = vaporRequest
        self.promise = vaporRequest.eventLoop.makePromise(of: Response.self)
        self.eventFactory = eventFactory
        self.handler = self

        var nextStr: EventLoopPromise<GRPCStream<RequestMessage.ModelType>> = vaporRequest.eventLoop.makePromise(of: GRPCStream<RequestMessage.ModelType>.self)
        let stream = GRPCStream<RequestMessage.ModelType>.start(nextStr.futureResult)
        let request = GRPCStreamRequest<RequestMessage.ModelType, ResponseMessage.ModelType>.init(messageStream: stream, vaporRequest: vaporRequest)

        let resposeBuffer = ByteBufferAllocator().buffer(capacity: 0)
        let response = try handler!.processResponse(request.responseStream, buffer: resposeBuffer)
        self.promise.succeed(response)

        eventFactory(request)
        vaporRequest.body.drain { bodyStream in
            switch bodyStream {
            case let .buffer(buff):
                guard let message = try? self.processRequest(buff) else {
                    return vaporRequest.eventLoop.makeSucceededFuture(())
                }
                let newNext = vaporRequest.eventLoop.makePromise(of: GRPCStream<RequestMessage.ModelType>.self)
                let nextStream = GRPCStream<RequestMessage.ModelType>.message(message, nextMessage: newNext.futureResult)
                nextStr.succeed(nextStream)
                nextStr = newNext
            case .end:
                nextStr.succeed(.end)
            case let .error(error):
                break
            }
            return vaporRequest.eventLoop.makeSucceededFuture(())
        }
    }

    func endResponse() {
        handler = nil
    }
}
