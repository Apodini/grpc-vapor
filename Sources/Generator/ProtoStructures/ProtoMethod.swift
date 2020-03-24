//
//  ProtoMethod.swift
//  
//
//  Created by Michael Schlicker on 17.02.20.
//

import Foundation

struct ProtoMethod {
    let name: String
    let parameterName: String
    let type: CallType
    let inputType: ProtoModel
    let outputType: ProtoModel

    var protoInputType: String {
        switch type {
        case .unaryCall, .serverStream:
            return inputType.protoSuffixName
        case .clientStream, .bidirectionalStream:
            return "stream " + inputType.protoSuffixName
        }
    }

    var protoOutputType: String {
        switch type {
        case .unaryCall, .clientStream:
            return outputType.protoSuffixName
        case .serverStream, .bidirectionalStream:
            return "stream " + outputType.protoSuffixName
        }
    }
}
