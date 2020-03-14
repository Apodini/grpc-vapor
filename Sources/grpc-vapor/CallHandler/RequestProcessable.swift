//
//  RequestProcessable.swift
//  
//
//  Created by Michael Schlicker on 15.01.20.
//

import Vapor
import GRPC

protocol RequestProcessable {
    associatedtype RequestMessage: GRPCMessage
    var vaporRequest: Request { get set }
    func processRequest(_ requestBuffer: ByteBuffer) throws -> RequestMessage.ModelType
}

extension RequestProcessable {
    func processRequest(_ requestBuffer: ByteBuffer) throws -> RequestMessage.ModelType {
        var messageReader = LengthPrefixedMessageReader(mode: .server,
                                                        compressionMechanism: vaporRequest.headers.contentCoding ?? .none)
        var requestBuffer = requestBuffer
        messageReader.append(buffer: &requestBuffer)
        guard var messageBuffer = try messageReader.nextMessage() else {
            throw GRPCError.error }
        guard let messageData = messageBuffer.readData(length: messageBuffer.readableBytes) else {
            throw GRPCError.error }
        let message = try RequestMessage(serializedData: messageData)
        return message.toModel()
    }
}
