//
//  File.swift
//  
//
//  Created by Ryan Mckinney on 3/13/23.
//

import Foundation
import SwiftUI
import AttributedString


public extension View {
    
    func setAttributedTextActionHandlers(_ handlers: [ASAttributedString.Action]) -> some View {
        self
            .environment(\.attributedTextActionHandler, handlers)
    }
}

private struct AttributedTextActionHandlerKey: EnvironmentKey {
    static let defaultValue: [ASAttributedString.Action] = []
}

extension EnvironmentValues {
    var attributedTextActionHandler: [ASAttributedString.Action] {
        get { self[AttributedTextActionHandlerKey.self] }
        set { self[AttributedTextActionHandlerKey.self] = newValue }
    }
}

//Observing the NSTextView
public struct TextActionObserver {
    public var checkings: [ASAttributedString.Checking]
    public var highlights: [ASAttributedString.Action.Highlight]
    public var callback: (ASAttributedString.Checking.Result) -> Void
    public init(_ checkings: [ASAttributedString.Checking],
                highlights: [ASAttributedString.Action.Highlight],
                callback: @escaping (ASAttributedString.Checking.Result) -> Void) {
        self.checkings = checkings
        self.highlights = highlights
        self.callback = callback
    }
}

private struct TextActionObserverKey: EnvironmentKey {
    static let defaultValue: [TextActionObserver] = []
}

extension EnvironmentValues {
    var textActionObservers: [TextActionObserver] {
        get { self[TextActionObserverKey.self] }
        set { self[TextActionObserverKey.self] = newValue }
    }
}

public extension View {
    func setAttributedTextActionObservers(_ observers: [TextActionObserver]) -> some View {
        self
            .environment(\.textActionObservers, observers)
    }
}
