//
//  File.swift
//  
//
//  Created by Michael Schlicker on 15.01.20.
//

import Vapor

public class ServerStreamingCallHandler<RequestMessage: GRPCMessage, ResponseMessage: GRPCMessage>: AnyCallHandler, RequestProcessable, StreamingResponseProcessable {

    public var vaporRequest: Request

    public var response: EventLoopFuture<Response> { return promise.futureResult }

    private var promise: EventLoopPromise<Response>
    private var request: GRPCServerStreamRequest<RequestMessage.ModelType, ResponseMessage.ModelType>?

    var procedureCall: ((GRPCServerStreamRequest<RequestMessage.ModelType, ResponseMessage.ModelType>) -> Void)
    var handler: ServerStreamingCallHandler<RequestMessage, ResponseMessage>?


    public init(vaporRequest: Request,
                procedureCall: @escaping ((GRPCServerStreamRequest<RequestMessage.ModelType, ResponseMessage.ModelType>) -> Void)) throws {
        self.vaporRequest = vaporRequest
        self.promise = vaporRequest.eventLoop.makePromise(of: Response.self)
        self.procedureCall = procedureCall
        self.handler = self

        vaporRequest.body.collect().whenSuccess { byteBuffer in
            guard let handler = self.handler,
                let byteBuffer = byteBuffer else { return }
            do {
                let requestMessage = try handler.processRequest(byteBuffer)

                let request = GRPCServerStreamRequest<RequestMessage.ModelType, ResponseMessage.ModelType>(message: requestMessage, vaporRequest: self.vaporRequest)
                handler.request = request
                procedureCall(request)

                let response = try handler.processResponse(request.responseStream, buffer: byteBuffer)
                self.promise.succeed(response)
            } catch {
                self.promise.succeed(handler.errorResponse)
            }
        }
    }

    func endResponse() {
        handler = nil
    }
}
