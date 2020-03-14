//
//  ResponseProcessable.swift
//  
//
//  Created by Michael Schlicker on 15.01.20.
//

import Vapor
import GRPC

protocol ResponseProcessable {
    associatedtype ResponseMessage: GRPCMessage
    var vaporRequest: Request { get set }
    func processResponse(_ responseModel: ResponseMessage.ModelType, buffer: ByteBuffer) throws -> Response
}

extension ResponseProcessable {
    func processResponse(_ responseModel: ResponseMessage.ModelType, buffer: ByteBuffer) throws -> Response {
        let responseMessageObject = ResponseMessage(modelObject: responseModel)
        guard let responseData = try? responseMessageObject.serializedData() else { throw GRPCError.error }
        var bodyBuffer = buffer
        bodyBuffer.clear()
        bodyBuffer.reserveCapacity(LengthPrefixedMessageWriter.metadataLength + responseData.count)
        bodyBuffer.writeInteger(Int8(0))
        bodyBuffer.writeInteger(UInt32(responseData.count))
        bodyBuffer.writeBytes(responseData)
        return Response(status: .ok,
                        version: .init(major: 2, minor: 0),
                        headers: vaporRequest.headers,
                        body: Response.Body(buffer: bodyBuffer))
    }
}
