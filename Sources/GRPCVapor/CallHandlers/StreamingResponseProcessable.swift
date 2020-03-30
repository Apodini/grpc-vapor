//
//  StreamingResponseProcessable.swift
//  
//
//  Created by Michael Schlicker on 15.01.20.
//

import Vapor
import GRPC 

protocol StreamingResponseProcessable: class {
    associatedtype ResponseMessage: GRPCMessage
    var vaporRequest: Request { get set }
    func processResponse(_ responseStream: GRPCStream<ResponseMessage.ModelType>, buffer: ByteBuffer?) throws -> Response
    func endResponse()
}

extension StreamingResponseProcessable {
    func processResponse(_ responseStream: GRPCStream<ResponseMessage.ModelType>, buffer: ByteBuffer?) throws -> Response {

        guard let buffer = buffer else { throw GRPCError.error }
        let streamWriter:((BodyStreamWriter) -> ()) = { [unowned self] writer in
            self.processResponseMessage(message: responseStream, writer: writer, buffer: buffer)
        }

        return Response(status: .ok,
                        version: .init(major: 2, minor: 0),
                        headers: vaporRequest.headers,
                        body: Response.Body.init(stream: streamWriter, count: 20_000))
    }

    private func processResponseMessage(message: GRPCStream<ResponseMessage.ModelType>, writer: BodyStreamWriter, buffer: ByteBuffer) {
        switch message {
        case let .message(modelMessage, nextMessage: nextMessage):
            let responseMessageObject = ResponseMessage(modelObject: modelMessage)
            guard let responseData = try? responseMessageObject.serializedData() else {
                _ = writer.write(.error(GRPCError.error))
                return
            }
            var bodyBuffer = ByteBufferAllocator.init()
                .buffer(capacity: LengthPrefixedMessageWriter.metadataLength + responseData.count)
            bodyBuffer.writeInteger(Int8(0))
            bodyBuffer.writeInteger(UInt32(responseData.count))
            bodyBuffer.writeBytes(responseData)
            let messageSent = vaporRequest.eventLoop.makePromise(of: Void.self)

            nextMessage.and(messageSent.futureResult)
                .whenSuccess { [unowned self] mess, _ in
                    self.processResponseMessage(message: mess, writer: writer, buffer: bodyBuffer)
                }

            writer.write(.buffer(bodyBuffer),
                         promise: messageSent)
        case .end:
            let endSent = vaporRequest.eventLoop.makePromise(of: Void.self)
            writer.write(.end, promise: endSent)
            endSent.futureResult.whenComplete { _ in
                self.endResponse()
            }
        case let .start(firstMessage):
            firstMessage.whenSuccess { mess in
                self.processResponseMessage(message: mess, writer: writer, buffer: buffer)
            }
        }
    }
}
