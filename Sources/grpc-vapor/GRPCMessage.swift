//
//  GRPCMessage.swift
//  
//
//  Created by Michael Schlicker on 14.12.19.
//

import Foundation
import SwiftProtobuf

public protocol GRPCMessage: Message {
    associatedtype ModelType: GRPCModel
    func toModel() -> ModelType
    init(modelObject: ModelType)
}
