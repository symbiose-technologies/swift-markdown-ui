//
//  File.swift
//  
//
//  Created by Ryan Mckinney on 3/13/23.
//

import Foundation
import SwiftUI


public struct AttributedSubstringHighlightRegexKey: EnvironmentKey {
    public static let defaultValue: String? = nil
}


public extension EnvironmentValues {
    var substringHighlightRegex: String? {
        get { self[AttributedSubstringHighlightRegexKey.self] }
        set { self[AttributedSubstringHighlightRegexKey.self] = newValue }
    }
}


public extension View {
    func setSubstringHighlightPattern(_ regexPattern: String?) -> some View {
        self
            .environment(\.substringHighlightRegex, regexPattern)
    }
}
