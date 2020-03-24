//
//  CallType.swift
//  
//
//  Created by Michael Schlicker on 03.02.20.
//

import Foundation

enum CallType {
    case unaryCall
    case clientStream
    case serverStream
    case bidirectionalStream

    init?(requestType: String) {
        switch requestType {
        case CallType.unaryCall.requestType:
            self = .unaryCall
        case CallType.clientStream.requestType:
            self = .clientStream
        case CallType.serverStream.requestType:
            self = .serverStream
        case CallType.bidirectionalStream.requestType:
            self = .bidirectionalStream
        default:
            return nil
        }
    }

    var requestType: String {
        switch self {
        case .unaryCall: return "GRPCRequest"
        case .clientStream: return "GRPCClientStreamRequest"
        case .serverStream: return "GRPCServerStreamRequest"
        case .bidirectionalStream: return "GRPCStreamRequest"
        }
    }

    var callHandlerType: String {
        switch self {
        case .unaryCall: return "UnaryCallHandler"
        case .clientStream: return "ClientStreamingCallHandler"
        case .serverStream: return "ServerStreamingCallHandler"
        case .bidirectionalStream: return "StreamingCallHandler"
        }
    }
}
