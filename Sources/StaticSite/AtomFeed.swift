//
//  File.swift
//  
//
//  Created by Chris Eidhof on 22.06.21.
//

import Foundation
import Swim

public struct FeedItem {
    public init(link: String, title: String, description: String, date: Date) {
        self.link = link
        self.title = title
        self.description = description
        self.date = date
    }
    
    var link: String // relative link
    var title: String
    var description: String
    var date: Date
}

public struct AtomFeed: NodeConvertible {
    public init(destination: String, title: String, absoluteURL: String, description: String, items: [FeedItem]) {
        self.destination = destination
        self.title = title
        self.absoluteURL = absoluteURL
        self.description = description
        self.items = items
    }
    
    let dateFormatter: DateFormatter = {
        var df = DateFormatter()
        df.locale = Locale(identifier: "en_us")
        df.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return df
    }()
    
    let destination: String
    let title: String
    let absoluteURL: String
    let feedPath: String = "/feed.xml"
    let description: String

    let items: [FeedItem]

    public func asNode() -> Node {
        rss(version: "2.0", xmlns: "http://www.w3.org/2005/Atom") {
            channel {
                title { self.title }
                description { description }
                link { absoluteURL }
                atomLink(href: "\(absoluteURL)\(feedPath)", rel: "self")
                items.map { post -> Node in
                    let permalink = "\(absoluteURL)\(post.link)"
                    return item {
                        title { post.title }
                        description {
                            post.description.replaceAbsoluteURLs(prefix: absoluteURL + "/")
                        }
                        pubDate {
                            post.date
                        }
                        link { permalink }
                        guid { permalink }
                    }
                }
            }
        }
    }
}

// This code is a modified version of https://github.com/robb/robb.swift/blob/main/Sources/robb.swift/Pages/AtomFeed.swift
extension AtomFeed {
    private func rss(version: String, xmlns: String, @NodeBuilder children: () -> NodeConvertible) -> Node {
        .element("rss", [ "version": version, "xmlns:atom": xmlns ], children().asNode())
    }
        
    private func description(@NodeBuilder children: () -> NodeConvertible) -> Node {
        .element("description", [:], children().asNode())
    }
    
    private func channel(@NodeBuilder children: () -> NodeConvertible) -> Node {
        .element("channel", [:], children().asNode())
    }

    private func title(children: () -> String) -> Node {
        .element("title", [:], %children().asNode()%)
    }

    private func guid(isPermaLink: Bool = true, children: () -> String) -> Node {
        .element("guid", ["isPermaLink": isPermaLink ? "true" : "false"], %children().asNode()%)
    }

    private func pubDate(date: () -> Date) -> Node {
        .element("pubDate", [:], %.text(dateFormatter.string(from: date()))%)
    }
    
    private func item(@NodeBuilder children: () -> NodeConvertible) -> Node {
        .element("item", [:], children().asNode())
    }
    
    private func atomLink(href: String, rel: String, type: String = "application/rss+xml") -> Node {
        .element("atom:link", [ "href": href, "rel": rel, "type": type], nil)
    }
    
    private func link(children: () -> String) -> Node {
        .element("link", [:], %children().asNode()%)
    }
}
