//
//  GRPCModel.swift
//  
//
//  Created by Michael Schlicker on 13.12.19.
//

import Foundation

public protocol GRPCModel {
    init()
}

@propertyWrapper
public struct GRPCAttribute<T> {
    private var value: T
    private var id: Int

    public var wrappedValue: T {
        get { value }
        set { value = newValue }
    }

    public init(wrappedValue: T, id: Int) {
        self.id = id
        self.value = wrappedValue
    }
}
