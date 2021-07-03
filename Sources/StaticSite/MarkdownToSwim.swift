//
//  File.swift
//  
//
//  Created by Chris Eidhof on 21.06.21.
//

import Foundation
import HTML
import CommonMark
import Swim

extension CommonMark.Inline: NodeConvertible {
    @NodeBuilder public func asNode() -> Swim.Node {
        switch self {
        case .text(text: let text):
            text
        case .softBreak:
            ""
        case .lineBreak:
            br()
        case .code(text: let text):
            %HTML.code { text }%
        case .html(text: let text):
            Node.raw(text)
        case .emphasis(children: let children):
            %HTML.em { children }%
        case .strong(children: let children):
            %HTML.strong { children }%
        case .custom(literal: let literal):
            literal
        case .link(children: let children, title: let title, url: let url):
            %a(href: url, title: title) {
                children
            }%
        case .image(children: _, title: let title, url: let url):
            %img(src: url, title: title)%
        }
    }
}

extension CommonMark.Block: NodeConvertible {
    @NodeBuilder public func asNode() -> Swim.Node {
        switch self {
        case .list(items: let items, type: let type):
            let list = items.map { item in li { item } }
            if type == .ordered {
                ol { list }
            } else {
                ul { list }
            }
        case .blockQuote(items: let items):
            blockquote { items }
        case .codeBlock(text: let text, language: let language):
            let cl = language.map { "\($0)" }
            pre {
                %HTML.code(class: cl) {
                    "\n"
                    text
                }%
            }
        case .html(text: let text):
            Node.raw(text)
        case .paragraph(text: let text):
            p { text }
        case .heading(text: let text, level: let level):
            switch level {
            case 1: h1 { text }
            case 2: h2 { text }
            case 3: h3 { text }
            case 4: h4 { text }
            case 5: h5 { text }
            default: h6 { text }
            }
        case .custom(literal: let literal):
            literal
        case .thematicBreak:
            hr()
        }
    }
}
