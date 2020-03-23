//
//  GRPCStream.swift
//  
//
//  Created by Michael Schlicker on 22.03.20.
//

import NIO

public enum GRPCStream<T: GRPCModel> {
    case start(EventLoopFuture<GRPCStream<T>>)
    case message(T, nextMessage: EventLoopFuture<GRPCStream<T>>)
    case end
}
