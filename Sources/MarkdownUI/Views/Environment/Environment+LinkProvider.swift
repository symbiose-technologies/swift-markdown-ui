//
//  File.swift
//  
//
//  Created by Ryan Mckinney on 3/3/23.
//

import Foundation
import SwiftUI

/// A type that augments a Text link display with additional attributes
///

public protocol LinkAttributeAugmenter {
    
    func augmentLinkAttributes(sourceAttributes: AttributeContainer, url: URL?, childrenText: String) -> AttributeContainer
}


//Does nothing and returns the received attributes
public struct DefaultLinkAttributeAugmenter: LinkAttributeAugmenter {
    public func augmentLinkAttributes(sourceAttributes: AttributeContainer, url: URL?, childrenText: String) -> AttributeContainer {
        return sourceAttributes
    }
    
    static var defaultAugmenter: LinkAttributeAugmenter { self.init() }
}


extension View {
    
    public func markdownLinkAttributeAugmenter(_ linkAttributeAugmenter: LinkAttributeAugmenter) -> some View {
        self
            .environment(\.linkAttributeAugmenter, linkAttributeAugmenter)
    }
}


private struct LinkAttributeAugmenterKey: EnvironmentKey {
    static let defaultValue: LinkAttributeAugmenter = DefaultLinkAttributeAugmenter.defaultAugmenter
}

extension EnvironmentValues {
    var linkAttributeAugmenter: LinkAttributeAugmenter {
        get { self[LinkAttributeAugmenterKey.self] }
        set {  self[LinkAttributeAugmenterKey.self] = newValue  }
    }
}
