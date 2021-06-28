extension Character {
    var isQuote: Bool {
        self == "\"" || self == "'"
    }
}

extension String {
    public func replaceAbsoluteURLs(prefix: String) -> String {
        let attributes = [
            "src=",
            "href=",
            "url=",
            "action=",
            "srcset="
        ] // https://github.com/gohugoio/hugo/blob/master/transform/urlreplacers/absurlreplacer.go
        
        let startingLetter = Set(attributes.map { $0.first! })
        
        var remainder = self[...]
        var result = ""
        while let f = remainder.first {
            if startingLetter.contains(f) {
                for a in attributes {
                    if remainder.remove(prefix: a) {
                        result.append(a)
                        guard remainder.first?.isQuote == true else { continue }
                        let q = remainder.removeFirst()
                        result.append(q)
                        if a == "srcset=" {
                            guard let endIdx = remainder.firstIndex(of: q) else { continue }
                            let srcset = remainder[..<endIdx]
                            let fields = srcset.split { $0.isWhitespace }
                            for var f in fields {
                                f.foo(prefix: prefix, result: &result)
                                result.append(contentsOf: f)
                                result.append(" ")
                            }
                            if !fields.isEmpty {
                                result.removeLast() // remove final space
                            }
                            remainder = remainder[endIdx...]
                        } else {
                            remainder.foo(prefix: prefix, result: &result)
                        }
                    }
                }
            }
            result.append(remainder.removeFirst())
        }
        
        return result
    }
}

extension Substring {
    mutating func foo(prefix: String, result: inout String) {
        guard first == "/" else {
            return
        }
        _ = removeFirst()
        guard first != "/" else { // schemaless URL
            result.append("/")
            return
        }
        result.append(prefix)
    }    
}
