import Foundation
import Swim

public struct Write: Builtin {
    public init(outputName: String, data: Data) {
        self.outputName = outputName
        self.data = data
    }
    
    var outputName: String
    var data: Data

    public func run(environment: EnvironmentValues) throws {
        var env = environment
        env.relativeOutputPath = (env.relativeOutputPath as NSString).appendingPathComponent(outputName)
        try env.write(data)
    }
}

public struct WriteNode: Builtin {
    public init(outputName: String, node: NodeConvertible, xml: Bool = false) {
        self.outputName = outputName
        self.node = node.asNode()
        self.xml = xml
    }
    
    var outputName: String
    var node: Node
    var xml: Bool

    public func run(environment: EnvironmentValues) throws {
        var env = environment
        env.relativeOutputPath = (env.relativeOutputPath as NSString).appendingPathComponent(outputName)
        let templates = environment.template
        var result = node
        for t in templates.reversed() {
            env.install(on: t)
            result = t.run(content: result)
        }
        result = env.transformNode(env, result)
        let output = result.render(xml: xml)
        try env.write(output.data(using: .utf8)!)
    }
}

extension Node {
    public func render(xml: Bool) -> String {
        // todo rather than traversing the tree twice we could merge the traversals
        
        var output = ""
        if xml {
            output.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
        }
        self.write(to: &output)
        return output
    }
}
