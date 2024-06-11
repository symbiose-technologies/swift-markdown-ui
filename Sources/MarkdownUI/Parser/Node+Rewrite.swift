//////////////////////////////////////////////////////////////////////////////////
//
//  SYMBIOSE
//  Copyright 2023 Symbiose Technologies, Inc
//  All Rights Reserved.
//
//  NOTICE: This software is proprietary information.
//  Unauthorized use is prohibited.
//
// 
// Created by: Ryan Mckinney on 10/24/23
//
////////////////////////////////////////////////////////////////////////////////

import Foundation


public struct InlineNodeOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let text         = InlineNodeOptions(rawValue: 1 << 0)
    public static let softBreak    = InlineNodeOptions(rawValue: 1 << 1)
    public static let lineBreak    = InlineNodeOptions(rawValue: 1 << 2)
    public static let code         = InlineNodeOptions(rawValue: 1 << 3)
    public static let html         = InlineNodeOptions(rawValue: 1 << 4)
    public static let emphasis     = InlineNodeOptions(rawValue: 1 << 5)
    public static let strong       = InlineNodeOptions(rawValue: 1 << 6)
    public static let strikethrough = InlineNodeOptions(rawValue: 1 << 7)
    public static let link         = InlineNodeOptions(rawValue: 1 << 8)
    public static let image        = InlineNodeOptions(rawValue: 1 << 9)
}



public extension Sequence where Element == InlineNode {
    func rewriteWithOptions(_ r: (InlineNode) throws -> [InlineNode], options: InlineNodeOptions) rethrows -> [InlineNode] {
        try self.flatMap { try $0.rewriteWithOptions(r, options: options) }
    }
}


public extension InlineNode {
    func rewriteWithOptions(_ r: (InlineNode) throws -> [InlineNode], options: InlineNodeOptions) rethrows -> [InlineNode] {
        var inline = self
        inline.children = try self.children.rewriteWithOptions(r, options: options)

        guard options.contains(self.rootNodeType) else {
            return [inline]
        }

        return try r(inline)
    }

    
    var rootNodeType: InlineNodeOptions {
        switch self {
        case .text:
            return .text
        case .softBreak:
            return .softBreak
        case .lineBreak:
            return .lineBreak
        case .code:
            return .code
        case .html:
            return .html
        case .emphasis:
            return .emphasis
        case .strong:
            return .strong
        case .strikethrough:
            return .strikethrough
        case .link:
            return .link
        case .image:
            return .image
        }
    }
}

public extension Sequence where Element == BlockNode {
   
    func rewrite(_ r: (InlineNode) throws -> [InlineNode], options: InlineNodeOptions) rethrows -> [BlockNode] {
        try self.flatMap { try $0.rewriteWithOptions(r, options: options) }
    }
}


public extension BlockNode {
    
    
    func rewriteWithOptions(_ r: (InlineNode) throws -> [InlineNode], options: InlineNodeOptions) rethrows -> [BlockNode] {
        switch self {
        case .blockquote(let children):
            return [.blockquote(children: try children.rewrite(r, options: options))]
        case .bulletedList(let isTight, let items):
            return [
                .bulletedList(
                    isTight: isTight,
                    items: try items.map {
                        RawListItem(children: try $0.children.rewrite(r, options: options))
                    }
                )
            ]
        case .numberedList(let isTight, let start, let items):
            return [
                .numberedList(
                    isTight: isTight,
                    start: start,
                    items: try items.map {
                        RawListItem(children: try $0.children.rewrite(r, options: options))
                    }
                )
            ]
        case .taskList(let isTight, let items):
            return [
                .taskList(
                    isTight: isTight,
                    items: try items.map {
                        RawTaskListItem(isCompleted: $0.isCompleted, children: try $0.children.rewrite(r, options: options))
                    }
                )
            ]
        case .paragraph(let content):
            return [.paragraph(content: try content.rewriteWithOptions(r, options: options))]
        case .heading(let level, let content):
            return [.heading(level: level, content: try content.rewriteWithOptions(r, options: options))]
        case .table(let columnAlignments, let rows):
            return [
                .table(
                    columnAlignments: columnAlignments,
                    rows: try rows.map {
                        RawTableRow(
                            cells: try $0.cells.map {
                                RawTableCell(content: try $0.content.rewriteWithOptions(r, options: options))
                            }
                        )
                    }
                )
            ]
        default:
            return [self]
        }
    }
}
