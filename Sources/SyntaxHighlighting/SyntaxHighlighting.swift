import Foundation
import SwiftSyntax

extension TriviaPiece {
    var isComment: Bool {
        switch self {
        case .lineComment, .blockComment, .docLineComment, .docBlockComment:
            return true
        default:
            return false
        }
    }
}

class SwiftSyntaxHighlighter: SyntaxRewriter {
    var html: String = ""
    
    func write(trivia: Trivia) {
        for piece in trivia {
            if piece.isComment {
                html.append("<span class=\"hljs-comment\">")
            }
            piece.write(to: &html)
            if piece.isComment {
                html.append("</span>")
            }
        }
    }

    override func visit(_ token: TokenSyntax) -> Syntax {
        write(trivia: token.leadingTrivia)
        switch token.tokenKind {
        case .floatingLiteral, .integerLiteral:
            html.append("<span class=\"hljs-number\">\(token.text)</span>")
        case _ where token.tokenKind.isKeyword:
            html.append("<span class=\"hljs-keyword\">\(token.text)</span>")
        case .identifier:
            html.append("<span class=\"hljs-identifier\">\(token.text)</span>")
        case .rawStringDelimiter, .stringSegment, .stringLiteral, .stringQuote, .multilineStringQuote:
            html.append("<span class=\"hljs-string\">\(token.text)</span>")
        default:
            html.append(token.text)
        }
        write(trivia: token.trailingTrivia)
        return Syntax(token)
    }
}

extension String {
    public var highlightedAsSwift: String {
        do {
            let parsed = try SyntaxParser.parse(source: self)
            let highlighter = SwiftSyntaxHighlighter()
            _ = highlighter.visit(parsed)
            return highlighter.html
        } catch {
            print(error)
            return self
        }
    }
}

