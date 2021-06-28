//
//  File.swift
//  
//
//  Created by Chris Eidhof on 11.04.20.
//

import Foundation

extension Character {
    public var isDecimalDigit: Bool {
        return self.isHexDigit && self.hexDigitValue! < 10 // todo?
    }
    
    public var isIdentifier: Bool {
        return isLetter || isNumber || self == "_" || self == "-"
    }
    
    public var isIdentifierStart: Bool {
        return isLetter || isNumber || self == "_"
    }
}

extension Substring {
    @discardableResult mutating public func remove(prefix: String) -> Bool {
        guard hasPrefix(prefix) else { return false }
        removeFirst(prefix.count)
        return true
    }
    
    @discardableResult
    mutating public func remove(while cond: (Element) -> Bool) -> Self? {
        guard let end = firstIndex(where: { !cond($0) }) else {
            let remainder = self
            self.removeAll()
            return remainder
        }
        let result = self[..<end]
        self = self[end..<endIndex]
        return result
    }
    
    @discardableResult
    mutating public func removeLine() -> Self? {
        guard let newLine = firstIndex(where: { $0.isNewline }) else {
            let result = self
            self.removeAll()
            return result
        }
        let end = self.index(after: newLine)
        let result = self[..<end]
        self = self[end..<endIndex]
        return result
    }
    
    mutating public func skipWS() {
        remove(while: { $0.isWhitespace })
    }
    
    mutating public func skipWSWithoutNewlines() {
        remove(while: { $0.isWhitespace && !$0.isNewline })
    }
}
