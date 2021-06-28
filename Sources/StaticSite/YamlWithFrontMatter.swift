//
//  File.swift
//  
//
//  Created by Chris Eidhof on 01.06.21.
//

import Foundation

extension String {
    // Parses a yaml front matter delimeted by ---
    public func parseMarkdownWithFrontMatter() throws -> (yaml: String?, markdown: String) {
        var remainder = self[...]
        remainder.remove(while: { $0.isWhitespace })
        if remainder.remove(prefix: "---") {
            let start = remainder.startIndex
            var end = remainder.startIndex
            while !remainder.isEmpty, !remainder.remove(prefix: "---") {
                remainder.removeLine()
                end = remainder.startIndex
            }
            let yaml = String(self[start..<end])
            return (yaml: yaml, markdown: String(remainder))
        }
        
        return (yaml: nil, markdown: self)
    }
}
