//
//  File.swift
//  
//
//  Created by Ryan Mckinney on 5/3/23.
//

import Foundation
import AttributedString

//linkattributeaugmenter

//highlighted text style
//highlighted substring regex

struct SymAugmentation {
    
    var highlightedStyle: TextStyle
    var highlightSubstringRegex: String?
    var linkAttributeAugmenter: LinkAttributeAugmenter
    var attributedTextActionHandlers: [ASAttributedString.Action]
}
