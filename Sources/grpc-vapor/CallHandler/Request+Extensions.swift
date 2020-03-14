//
// Request+Extensions.swift
//  
//
//  Created by Michael Schlicker on 13.03.20.
//

import NIOHTTP1
import GRPC

extension HTTPHeaders {
    var contentCoding: CompressionMechanism? {
        guard let coding = first(name: "Content-Coding") else { return nil }
        return CompressionMechanism(rawValue: coding)
    }
}
