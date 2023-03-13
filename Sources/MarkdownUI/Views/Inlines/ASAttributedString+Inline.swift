//
//  File.swift
//  
//
//  Created by Ryan Mckinney on 3/10/23.
//

import Foundation
import AttributedString
import SwiftUI

#if os(iOS)
import UIKit
#endif

extension ASAttributedString {
    
    static func createFrom(inlines: [Inline],
         images: [String: Image],
         environment: InlineEnvironment,
         attributes: AttributeContainer,
         linkAugmenter: LinkAttributeAugmenter,
        substringHighlightRegex: String?,
        textActions: [ASAttributedString.Action] = []
    ) -> ASAttributedString {
        let string = inlines.reduce(into: ASAttributedString(stringLiteral: "")) {
            $0 += createFor(inline: $1,
                            environment: environment,
                            attributes: attributes,
                            linkAugmenter: linkAugmenter,
                            substringHighlightRegex: substringHighlightRegex,
                            textActions: textActions)
        }
        
        return string
    }
    
    static func createFor(inline: Inline,
         environment: InlineEnvironment,
         attributes: AttributeContainer,
         linkAugmenter: LinkAttributeAugmenter,
         substringHighlightRegex: String?,
         textActions: [ASAttributedString.Action] = []) -> ASAttributedString {
        let native = AttributedString(inline: inline, environment: environment, attributes: attributes, linkAugmenter: linkAugmenter)
            .resolvingFonts()
        var attr = ASAttributedString(NSAttributedString(string: inline.text))
        
        for run in native.runs {
            let attributeDict: [NSAttributedString.Key: Any] = run.attributes.toNSDictionary()
            
            attr.set(attributes: [.custom(attributeDict)], range: NSRange(run.range, in: native))
            if let substringHighlightRegex = substringHighlightRegex {
                let substringHighlightContainer = environment.highlighted.mergingAttributes(attributes)
                let substringHighlightDic = substringHighlightContainer.toNSDictionary()
                attr.add(attributes: [.custom(substringHighlightDic)], checkings: [.regex(substringHighlightRegex)])
            }
        }
        for action in textActions {
            attr.add(attributes: [.action(action)])
        }
        
        return attr
    }
    
    
}

extension AttributeContainer {
    
    func toNSDictionary() -> [NSAttributedString.Key: Any] {
        var attributeDict: [NSAttributedString.Key: Any] = [:]
        if let markdownUI = try? Dictionary(self, including: \.markdownUI) {
            attributeDict.merge(markdownUI) { (_, new) in new }
        }
        if let accessibility = try? Dictionary(self, including: \.accessibility) {
            attributeDict.merge(accessibility) { (_, new) in new }
        }
        if let foundation = try? Dictionary(self, including: \.foundation) {
            attributeDict.merge(foundation) { (_, new) in new }
        }
        if let swiftUI = try? Dictionary(self, including: \.swiftUI) {
            attributeDict.merge(swiftUI) { (_, new) in new }
        }
        
        #if os(macOS)
        if let appKit = try? Dictionary(self, including: \.appKit) {
            attributeDict.merge(appKit) { (_, new) in new }
        }
        if let foregroundC = self.swiftUI.foregroundColor {
            attributeDict[.foregroundColor] = NSColor(foregroundC)
        }
        if let backgroundC = self.swiftUI.backgroundColor {
            attributeDict[.backgroundColor] = NSColor(backgroundC)
        }
        if let link = attributeDict.removeValue(forKey: .link) as? URL {
            attributeDict[.macLink] = link
            attributeDict[.cursor] = NSCursor.pointingHand
        }
        #elseif os(iOS)
        if let uiKit = try? Dictionary(self, including: \.uiKit) {
            attributeDict.merge(uiKit) { (_, new) in new }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineBreakStrategy = .standard
            attributeDict[.paragraphStyle] = paragraphStyle
        }
        #endif
        return attributeDict
    }
    
}
