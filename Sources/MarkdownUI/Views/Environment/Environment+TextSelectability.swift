//
//  File.swift
//  
//
//  Created by Ryan Mckinney on 3/27/23.
//

import Foundation
import SwiftUI


extension View {
    
    
    public func setRichTextSelectability(isSelectable: Bool) -> some View {
        self.environment(\.richTextSelectability, isSelectable)
    }
    
}

extension EnvironmentValues {
    var richTextSelectability: Bool {
        get { self[RichTextSelectabilityKey.self] }
        set { self[RichTextSelectabilityKey.self] = newValue }
    }
}

private struct RichTextSelectabilityKey: EnvironmentKey {
    static let defaultValue: Bool = true
}
