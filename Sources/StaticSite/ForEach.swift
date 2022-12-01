//
//  File.swift
//  
//
//  Created by Chris Eidhof on 01.06.21.
//

import Foundation

public struct ForEach<Element, Content: Rule>: Builtin {
    public init(_ data: [Element], @RuleBuilder content: @escaping (Element) -> Content) {
        self.data = data
        self.content = content
    }
    
    var data: [Element]
    var content: (Element) -> Content
    var parallel: Bool = false // this can cause problems with the environment!
    
    public func run(environment: EnvironmentValues) throws {
        if parallel {
            let group = DispatchGroup()
            let q = DispatchQueue.global()
            for element in data {
                group.enter()
                q.async {
                    try! content(element).builtin.run(environment: environment)
                    group.leave()
                }
            }
            group.wait()
        } else {
            for element in data {
                try content(element).builtin.run(environment: environment)
            }
        }
    }
}
