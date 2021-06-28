//
//  File.swift
//  
//
//  Created by Chris Eidhof on 14.06.21.
//

import Foundation


public struct Copy: Rule, BuiltinRule {
    public init(_ name: String) {
        self.init(from: name, to: name)
    }
    
    public init(from: String, to: String) {
        self.from = from
        self.to = to
    }
    
    public init(contentsOf: String, to: String) {
        self.from = contentsOf
        self.to = to
        copyContents = true
    }
    
    var copyContents = false
    var from: String
    var to: String
    
    public func run(environment: EnvironmentValues) throws {
        let fm = FileManager.default
        let source = environment.inputBaseURL.appendingPathComponent(from)
        let destination = environment.output.appendingPathComponent(to)
        let destinationDir = destination.deletingLastPathComponent()
        if !fm.fileExists(atPath: destinationDir.path, isDirectory: nil) {
            try fm.createDirectory(at: destinationDir, withIntermediateDirectories: true, attributes: nil)
        }
        if copyContents {
            let paths = try fm.contentsOfDirectory(atPath: source.path)
            for p in paths {
                try fm.copyItem(at: source.appendingPathComponent(p), to: destination.appendingPathComponent(p))
            }
        } else {
            try fm.copyItem(at: source, to: destination)
            let base = environment.inputBaseURL
            let hashed = environment.hashedAssetNames
            let out = environment.output
            for file in fm.allFiles(at: source) {
                if let dest = hashed[file] {
                    try fm.copyItem(at: base.appendingPathComponent(file), to: out.appendingPathComponent(dest))
                }
            }
        }
    }
}
