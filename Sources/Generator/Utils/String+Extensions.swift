//
//  File.swift
//  
//
//  Created by Michael Schlicker on 02.02.20.
//

import Foundation

extension String {
    func removeSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "  ", with: "")
    }
}
