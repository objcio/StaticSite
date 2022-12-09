//
//  File.swift
//  
//
//  Created by Chris Eidhof on 21.06.21.
//

import Foundation
import HTML
import Markdown
import Swim

extension Markup {
    public func toNode() -> Node {
        var b = HTMLBuilder()
        return b.visit(self)
    }
}

extension String {
    public func markdown() -> Node {
        Document(parsing: self).toNode()
    }
}

// todo should this be a visitor?
struct HTMLBuilder: MarkupVisitor {
    typealias Result = Node

    mutating func visit(_ children: MarkupChildren) -> Node {
        .fragment(children.map { visit($0) })
    }

    mutating func defaultVisit(_ markup: Markup) -> Node {
        visit(markup.children)
    }


    func visitText(_ text: Markdown.Text) -> Node {
        text.string.asNode()
    }

    func visitLineBreak(_ lineBreak: LineBreak) -> Node{
        br()
    }


    func visitInlineHTML(_ inlineHTML: InlineHTML) -> Node {
        .raw(inlineHTML.rawHTML)
    }

    mutating func visitEmphasis(_ emphasis: Emphasis) -> Node {
        %HTML.em { visit(emphasis.children) }
    }

    mutating func visitStrong(_ strong: Strong) -> Node {
        %HTML.strong { visit(strong.children) }
    }
    func visitCustomInline(_ customInline: CustomInline) -> Node {
        customInline.text.asNode()
    }

    mutating func visitLink(_ link: Link) -> Node {
        %a(href: link.destination) {
            visit(link.children)
        }%
    }

    func visitImage(_ image: Image) -> Node {
        %img(src: image.source, title: image.title)%
    }

    mutating func visitOrderedList(_ orderedList: OrderedList) -> Node {
        ol { visit(orderedList.children) }
    }

    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> Node {
        ul { visit(unorderedList.children) }
    }

    mutating func visitListItem(_ listItem: ListItem) -> Node {
        li { visit(listItem.children) }
    }

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> Node {
        blockquote { visit(blockQuote.children) }
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Node {
        let cl = codeBlock.language
        return pre {
            %HTML.code(class: cl) {
                codeBlock.code
            }%
        }
    }

    func visitInlineCode(_ inlineCode: InlineCode) -> Node {
        %HTML.code { inlineCode.code }%
    }

    func visitHTMLBlock(_ html: HTMLBlock) -> Node {
        .raw(html.rawHTML)
    }

    mutating func visitHeading(_ heading: Heading) -> Node {
        let text = visit(heading.children)
        switch heading.level {
        case 1: return h1 { text }
        case 2: return h2 { text }
        case 3: return h3 { text }
        case 4: return h4 { text }
        case 5: return h5 { text }
        default: return h6 { text }
        }
    }

    mutating func visitParagraph(_ paragraph: Paragraph) -> Node {
        p { visit(paragraph.children) }
    }

    func visitThematicBreak(_ thematicBreak: ThematicBreak) -> Node {
        hr()
    }

    mutating func visitCustomBlock(_ customBlock: CustomBlock) -> Node {
        visit(customBlock.children)
    }
}

