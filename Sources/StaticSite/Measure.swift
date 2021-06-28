//
//  File.swift
//  
//
//  Created by Chris Eidhof on 15.06.21.
//

import Foundation

fileprivate struct Measure<R: Rule>: BuiltinRule, Rule {
    var rule: R
    
    func run(environment: EnvironmentValues) throws {
        let start = Date()
        try rule.builtin.run(environment: environment)
        let end = Date()
        print("\(R.self): \(end.timeIntervalSince(start))")
    }
}

extension Rule {
    public func measure() -> some Rule {
        Measure(rule: self)
    }
}
