//
//  GRPCMiddleware.swift
//  
//
//  Created by Michael Schlicker on 13.12.19.
//

import Foundation
import Vapor

public class GRPCMiddleware: Middleware {

    var services: [String: GRPCService] = [:]
//    private var openHandlers: [Int: StreamingCallHandler] = [:]

    func addService(_ service: GRPCService) {
        services[service.serviceName] = service
    }

    public init(services: [GRPCService]) {
        services.forEach(addService)
    }

    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard request.headers["content-type"].contains("application/grpc") else {
            return next.respond(to: request)
        }

        guard let callHandler = self.getCallHandler(request: request) else {
            return request.eventLoop.makeFailedFuture(GRPCError.error)
        }

        return callHandler.response.always { result in
            switch result {
            case let .success(response):
                print(response)
            case .failure(_):
                print("err")
            }
        }
    }

    func getCallHandler(request: Request) -> AnyCallHandler? {
        let components = request.url.path.components(separatedBy: "/")
        guard components.count >= 3 else { return nil }
        let serviceName = components[1]
        let service = services[serviceName]
        let methodName = components[2]

        return service?.handleMethod(methodName: methodName, vaporRequest: request)
    }
}
