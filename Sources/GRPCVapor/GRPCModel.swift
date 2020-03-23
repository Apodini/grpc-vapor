//
//  GRPCModel.swift
//  
//
//  Created by Michael Schlicker on 13.12.19.
//

import Foundation

/**
`GRPCModel` is a protocol that is implemented by models in the existing code to declare them ad gRPC messages.

 It provides **NO** conformance to the `SwiftProtobuf.Message` protocol which is used to encode and decode protocol buffer messages. This functionality is realitzed by provided by the `GRPCMessage`protocol.
 This protocol requires the models to contain an empty initializer to make code generated mappings between `GRPCModel`  and `GRPCMessage` instances easier.
*/

public protocol GRPCModel {

    /**
    Initializes a `GRPCModel` without any parameter.
     The implementations of this initializer should provide an initialization with default values.
    */
    init()
}
