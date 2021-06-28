//
//  File.swift
//  
//
//  Created by Chris Eidhof on 21.06.21.
//

import Foundation
import Swim
#if os(Linux)
import Crypto
#else
import CryptoKit
#endif

extension FileManager {
    func allFiles(at: URL) -> [String] {
        var result: [String] = []
        allFiles_(at: at, prefix: "", result: &result)
        return result
    }
    private func allFiles_(at: URL, prefix: String, result: inout [String]) {
        var isDir: ObjCBool = false
        guard fileExists(atPath: at.path, isDirectory: &isDir) else { return }
        if isDir.boolValue {
            let p = prefix.appending("/" + at.lastPathComponent)
            if let files = try? contentsOfDirectory(atPath: at.path) {
                for c in files {
                    allFiles_(at: at.appendingPathComponent(c), prefix: p, result: &result)
                }
            }
        } else {
            result.append(prefix + "/" + at.lastPathComponent)
        }
    }
}

// TODO I think this could be parallelized
public func hashAssetNames(source: String, environment: EnvironmentValues) -> [String:String] {
    let root = environment.inputBaseURL
    let allFiles = FileManager.default.allFiles(at: root.appendingPathComponent(source))
    var result: [String:String] = [:]
    for input in allFiles {
        let data = try! Data(contentsOf: root.appendingPathComponent(input))
        let shaString = "_" + Insecure.SHA1.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        var copy = input
        if let dot = copy.lastIndex(of: ".") {
            copy.insert(contentsOf: shaString.prefix(8), at: dot)
        } else {
            fatalError("\(copy) does not contain an extension, cannot hash.")
        }
        result[input] = copy
    }
    return result
}

extension Node {
    public func withHashedAssets(_ assets: [String:String]) -> Node {
        AssetHasher(assets: assets).visitNode(self)
    }
}

let urlProperties: Set<String> = [
    "src",
    "href",
    "url",
    "action",
    "srcset",
]

struct AssetHasher: Visitor {
    typealias Result = Node
    var assets: [String:String]
    
    func visitRaw(raw: String) -> Node {
        return .raw(raw)
    }
    
    func visitElement(name: String, attributes: [String : String], child: Node?) -> Node {
        guard attributes.keys.contains(where: { urlProperties.contains($0) }) else {
            return .element(name, attributes, child.map(visitNode))
        }
        var new: [String:String] = [:]
        for (key, value) in attributes {
            var newValue = value
            if urlProperties.contains(key) {
                if key == "srcset" {
                    newValue = value.split(whereSeparator: { $0.isWhitespace}).map {
                        assets[String($0)] ?? String($0)
                    }.joined(separator: " ")
                } else {
                    newValue = assets[value] ?? newValue
                }
            }
            new[key] = newValue
        }
        return .element(name, new, child.map(visitNode))
    }
}
