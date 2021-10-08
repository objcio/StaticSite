//
//  File.swift
//  
//
//  Created by Chris Eidhof on 28.06.21.
//

import Foundation
import Swim

enum TemplateKey: EnvironmentKey {
    static var defaultValue: [Template] = []
}

extension EnvironmentValues {
    public var template: [Template] {
        get { self[TemplateKey.self] }
        set { self[TemplateKey.self] = newValue }
    }
}

extension Rule {
    public func wrap(_ template: Template) -> some Rule {
        self.modifyEnvironment(keyPath: \.template, modify: { $0.append(template) })
    }
    
    public func resetTemplates() -> some Rule {
        self.modifyEnvironment(keyPath: \.template, modify: { $0 = [] })
    }
}

public protocol Template {
    func run(content: Node) -> Node
}
