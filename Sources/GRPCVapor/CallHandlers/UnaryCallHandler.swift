//
//  UnaryCallHandler.swift
//  
//
//  Created by Michael Schlicker on 15.01.20.
//

import Vapor

public class UnaryCallHandler<RequestMessage: GRPCMessage, ResponseMessage: GRPCMessage>: AnyCallHandler, RequestProcessable, ResponseProcessable {

    public var vaporRequest: Request

    public var response: EventLoopFuture<Response> { return promise.futureResult }

    private var promise: EventLoopPromise<Response>

    public var eventObserverFactory: (GRPCRequest<RequestMessage.ModelType>) -> EventLoopFuture<ResponseMessage.ModelType>

    public init(vaporRequest: Request, eventObserverFactory: @escaping (GRPCRequest<RequestMessage.ModelType>) -> EventLoopFuture<ResponseMessage.ModelType>) throws {
        self.vaporRequest = vaporRequest
        self.eventObserverFactory = eventObserverFactory

        self.promise = vaporRequest.eventLoop.makePromise(of: Response.self)

        vaporRequest.body.collect().whenSuccess { byteBuffer in
            do {
                guard let byteBuffer = byteBuffer else { throw GRPCError.error }
                let requestMessage = try self.processRequest(byteBuffer)
                let request = GRPCRequest<RequestMessage.ModelType>(message: requestMessage,
                                                                    vaporRequest: self.vaporRequest)

                _ = eventObserverFactory(request)
                    .map { responseModel in
                        
                        do {
                            let response = try self.processResponse(responseModel, buffer: byteBuffer)
                            self.promise.succeed(response)
                        } catch {
                            self.promise.succeed(self.errorResponse)
                        }
                    }
            } catch {
                self.promise.succeed(self.errorResponse)
            }
        }
    }

}
