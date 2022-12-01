//
//  File.swift
//  
//
//  Created by Chris Eidhof on 31.05.21.
//

import Foundation
import Swim

public protocol EnvironmentKey {
    associatedtype Value
    static var defaultValue: Value { get }
}

public struct EnvironmentValues {
    public init(fileManager: FileManager = FileManager.default, inputBaseURL: URL, outputBaseURL: URL) {
        self.fileManager = fileManager
        self.inputBaseURL = inputBaseURL
        self.outputBaseURL = outputBaseURL
        self.transformNode = { $1 }
    }
    
    public var fileManager = FileManager.default
    public var inputBaseURL: URL
    public internal(set) var relativeOutputPath = "/"
    public var templates: [Template] = []
    public var outputBaseURL: URL
    public var output: URL {
        outputBaseURL.appendingPathComponent(relativeOutputPath)
    }
    public var transformNode: (EnvironmentValues, Node) -> Node // this runs before rendering a node
    var userDefined: [ObjectIdentifier:Any] = [:]

    public subscript<Key: EnvironmentKey>(key: Key.Type = Key.self) -> Key.Value {
        get {
            userDefined[ObjectIdentifier(key)] as? Key.Value ?? Key.defaultValue
        }
        set {
            userDefined[ObjectIdentifier(key)] = newValue
        }
    }
}

enum HashedAssetNames: EnvironmentKey {
    static var defaultValue: [String:String] = [:]
}

extension EnvironmentValues {
    public var hashedAssetNames: [String:String] {
        get {
            self[HashedAssetNames.self]
        }
        set {
            self[HashedAssetNames.self] = newValue
        }
    }
}

extension Rule {
    public func hashedAssetNames(_ names: [String:String]) -> some Rule {
        modifyEnvironment(keyPath: \.hashedAssetNames, modify: { $0.merge(names, uniquingKeysWith: { fatalError("Duplicate asset name \($1)" )}) })
    }
}

extension EnvironmentValues {
    public var currentPath: URL {
        inputBaseURL
    }
    
    public func allFiles(at relativePath: String) throws -> [String] {
        try fileManager.contentsOfDirectory(atPath: inputBaseURL.appendingPathComponent(relativePath).path)
    }
    
    public func read(_ relativePath: String) throws -> String {
        return try String(contentsOf: currentPath.appendingPathComponent(relativePath))
    }
    
    public func read(_ relativePath: String) throws -> Data {
        return try Data(contentsOf: currentPath.appendingPathComponent(relativePath))
    }
}

struct EnvironmentModifier<A, Content: Rule>: Builtin {
    init(content: Content, keyPath: WritableKeyPath<EnvironmentValues, A>, modify: @escaping (inout A) -> ()) {
        self.content = content
        self.keyPath = keyPath
        self.modify = modify
    }
    
    var content: Content
    var keyPath: WritableKeyPath<EnvironmentValues, A>
    var modify: (inout A) -> ()
    
    func run(environment: EnvironmentValues) throws {
        var copy = environment
        modify(&copy[keyPath: keyPath])
        try content.builtin.run(environment: copy)
    }
}

public extension Rule {
    func environment<A>(keyPath: WritableKeyPath<EnvironmentValues, A>, value: A) -> some Rule {
        EnvironmentModifier(content: self, keyPath: keyPath, modify: { $0 = value })
    }
    
    func modifyEnvironment<A>(keyPath: WritableKeyPath<EnvironmentValues, A>, modify: @escaping (inout A) -> ()) -> some Rule {
        EnvironmentModifier(content: self, keyPath: keyPath, modify: modify )
    }
}

// Convenience

extension Rule {
    public func outputPath(_ string: String) -> some Rule {
        modifyEnvironment(keyPath: \.relativeOutputPath, modify: { path in
            path = (path as NSString).appendingPathComponent(string)
        })
    }
}

extension EnvironmentValues {
    public func write(_ data: Data) throws {
        let name = output
        let directory = name.deletingLastPathComponent()
        var isDirectory: ObjCBool = false
        let dirExists = fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory)
        if !dirExists || !isDirectory.boolValue {
            try? fileManager.removeItem(at: directory)
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        try data.write(to: name)
    }
}

public struct EnvironmentReader<R: Rule>: Builtin {
    var content: (EnvironmentValues) -> R
    
    public init(@RuleBuilder _ r: @escaping (EnvironmentValues) -> R) {
        self.content = r
    }
    public func run(environment: EnvironmentValues) throws {
        try content(environment)
            .builtin
            .run(environment: environment)
    }
}
