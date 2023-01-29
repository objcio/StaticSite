import Foundation

public protocol BuiltinRule {
    func run(environment: EnvironmentValues) throws
}

public typealias Builtin = BuiltinRule & Rule

public struct AnyBuiltin: Builtin {
    let _run: (EnvironmentValues) throws -> ()
    
    public init<R: Rule>(_ value: R) {
        self._run = { env in
            env.install(on: value)
            try value.body.builtin.run(environment: env)
        }
    }

    public init(any value: any Rule) {
        if let b = value as? any Builtin {
            self._run = { try b.run(environment: $0) }
        } else {
            self._run = { env in
                env.install(on: value)
                try value.body.builtin.run(environment: env)
            }
        }
    }

    public func run(environment: EnvironmentValues) throws {
        try _run(environment)
    }
}

public extension BuiltinRule {
    typealias Body = Never
    var body: Never {
        fatalError("This should never happen")
    }
}

extension Rule where Body == Never {
    func run() { fatalError() }
}

extension Never: Rule {
    public typealias Body = Never
    public var body: Never { fatalError() }
}

public protocol Rule {
    associatedtype Body: Rule
    @RuleBuilder var body: Body { get }
}

extension Rule {
    public var builtin: BuiltinRule {
        if let x = self as? BuiltinRule { return x }
        return AnyBuiltin(self)
    }
}

public struct EmptyRule: Builtin {
    public init() { }
    public func run(environment: EnvironmentValues) { }
}

extension Optional: Builtin where Wrapped: Rule {
    public func run(environment: EnvironmentValues) throws {
        try self?.builtin.run(environment: environment)
    }
}

public struct RuleGroup<Content: Rule>: Builtin {
    var content: Content
    
    public init(@RuleBuilder content: () -> Content) {
        self.content = content()
    }
    
    public func run(environment: EnvironmentValues) throws {
        try content.builtin.run(environment: environment)
    }
}

public struct Pair<L, R>: Builtin where L: Rule, R: Rule {
    var value: (L, R)
    init(_ l: L, _ r: R) {
        self.value = (l,r)
    }
    
    public func run(environment: EnvironmentValues) throws {
        try value.0.builtin.run(environment: environment)
        try value.1.builtin.run(environment: environment)
    }
}

public enum Choice<L, R>: Builtin where L: Rule, R: Rule {
    case left(L)
    case right(R)

    public func run(environment: EnvironmentValues) throws {
        switch self {
        case .left(let rule):
            try rule.builtin.run(environment: environment)
        case .right(let rule):
            try rule.builtin.run(environment: environment)
        }
    }
}

@resultBuilder
public enum RuleBuilder {
    public static func buildBlock() -> EmptyRule {
        EmptyRule()
    }
    
    public static func buildIf<Content>(_ content: Content?) -> Content? where Content : Rule {
        content
    }
    
    public static func buildBlock<Content>(_ content: Content) -> Content where Content : Rule {
        content
    }

    public static func buildEither<L, R>(first component: L) -> Choice<L, R> {
        .left(component)
    }

    public static func buildEither<L, R>(second component: R) -> Choice<L, R> {
        .right(component)
    }


    public static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) -> Pair<C0, C1> where C0 : Rule, C1 : Rule {
        return Pair(c0, c1)
    }
    
    public static func buildBlock<C0, C1, C2>(_ c0: C0, _ c1: C1, _ c2: C2) -> Pair<C0, Pair<C1, C2>> where C0 : Rule, C1 : Rule, C2: Rule {
        return Pair(c0, Pair(c1, c2))
    }
    
    public static func buildBlock<C0, C1, C2, C3>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) -> Pair<C0, Pair<C1, Pair<C2, C3>>> where C0 : Rule, C1 : Rule, C2: Rule, C3: Rule {
        return Pair(c0, Pair(c1, Pair(c2, c3)))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> Pair<C0, Pair<C1, Pair<C2, Pair<C3, C4>>>> where C0 : Rule, C1 : Rule, C2: Rule, C3: Rule, C4: Rule {
        return Pair(c0, Pair(c1, Pair(c2, Pair(c3, c4))))
    }

    public static func buildBlock<C0, C1, C2, C3, C4, C5>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) -> Pair<C0, Pair<C1, Pair<C2, Pair<C3, Pair<C4, C5>>>>> where C0 : Rule, C1 : Rule, C2: Rule, C3: Rule, C4: Rule, C5: Rule {
        return Pair(c0, Pair(c1, Pair(c2, Pair(c3, Pair(c4, c5)))))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> Pair<C0, Pair<C1, Pair<C2, Pair<C3, Pair<C4, Pair<C5, C6>>>>>> where C0 : Rule, C1 : Rule, C2: Rule, C3: Rule, C4: Rule, C5: Rule, C6: Rule {
        return Pair(c0, Pair(c1, Pair(c2, Pair(c3, Pair(c4, Pair(c5, c6))))))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) -> Pair<C0, Pair<C1, Pair<C2, Pair<C3, Pair<C4, Pair<C5, Pair<C6, C7>>>>>>> where C0 : Rule, C1 : Rule, C2: Rule, C3: Rule, C4: Rule, C5: Rule, C6: Rule, C7: Rule {
        return Pair(c0, Pair(c1, Pair(c2, Pair(c3, Pair(c4, Pair(c5, Pair(c6, c7)))))))
    }

    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) -> Pair<C0, Pair<C1, Pair<C2, Pair<C3, Pair<C4, Pair<C5, Pair<C6, Pair<C7, C8>>>>>>>> where C0 : Rule, C1 : Rule, C2: Rule, C3: Rule, C4: Rule, C5: Rule, C6: Rule, C7: Rule, C8: Rule {
        return Pair(c0, Pair(c1, Pair(c2, Pair(c3, Pair(c4, Pair(c5, Pair(c6, Pair(c7, c8))))))))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9) -> Pair<C0, Pair<C1, Pair<C2, Pair<C3, Pair<C4, Pair<C5, Pair<C6, Pair<C7, Pair<C8, C9>>>>>>>>> where C0 : Rule, C1 : Rule, C2: Rule, C3: Rule, C4: Rule, C5: Rule, C6: Rule, C7: Rule, C8: Rule, C9: Rule {
        return Pair(c0, Pair(c1, Pair(c2, Pair(c3, Pair(c4, Pair(c5, Pair(c6, Pair(c7, Pair(c8, c9)))))))))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9, _ c10: C10) -> Pair<C0, Pair<C1, Pair<C2, Pair<C3, Pair<C4, Pair<C5, Pair<C6, Pair<C7, Pair<C8, Pair<C9, C10>>>>>>>>>> where C0 : Rule, C1 : Rule, C2: Rule, C3: Rule, C4: Rule, C5: Rule, C6: Rule, C7: Rule, C8: Rule, C9: Rule, C10: Rule {
        return Pair(c0, Pair(c1, Pair(c2, Pair(c3, Pair(c4, Pair(c5, Pair(c6, Pair(c7, Pair(c8, Pair(c9, c10))))))))))
    }
}
