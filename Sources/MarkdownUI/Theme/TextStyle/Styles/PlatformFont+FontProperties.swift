//
//  File.swift
//  
//
//  Created by Ryan Mckinney on 3/13/23.
//

import Foundation
import SwiftUI

#if os(macOS)
import AppKit

extension NSFont {
    
    static func createFrom(from properties: FontProperties) -> NSFont {
        let size = properties.scaledSize
        let weight = properties.weight.appKitWeight
        
        switch properties.family {
        case .system(let design):
            let font: NSFont
            switch design {
            case .default:
                font = NSFont.systemFont(ofSize: size, weight: weight)
            case .serif:
                font = NSFont.systemFont(ofSize: size, weight: weight)
            case .rounded:
                font = NSFont.systemFont(ofSize: size, weight: weight)
            case .monospaced:
                
                font = NSFont.monospacedSystemFont(ofSize: size, weight: weight)
            @unknown default:
                font = NSFont.systemFont(ofSize: size, weight: weight)
            }
            return  font.applyVariants(properties: properties)
        case .custom(let name):
            guard let font = NSFont(name: name, size: size) else {
                fatalError("Failed to create NSFont for custom font name '\(name)'")
            }
            return font.applyVariants(properties: properties)
        }
    }
    
    
    func applyVariants(properties: FontProperties) -> NSFont {
        var font = self
        switch properties.capsVariant {
        case .normal:
            break
        case .smallCaps:
            font = NSFontManager.shared.convert(font, toHaveTrait: .smallCapsFontMask)
        case .lowercaseSmallCaps:
            font = NSFontManager.shared.convert(font, toHaveTrait: .smallCapsFontMask)
        case .uppercaseSmallCaps:
            font = NSFontManager.shared.convert(font, toHaveTrait: .smallCapsFontMask)
        }
        
        switch properties.style {
        case .normal:
          break  // do nothing
        case .italic:
            font = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
        }
        return font
    }
}

extension Font.Weight {
    var appKitWeight: NSFont.Weight {
        switch self {
        case .ultraLight:
            return .ultraLight
        case .thin:
            return .thin
        case .light:
            return .light
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        case .heavy:
            return .heavy
        case .black:
            return .black
        default:
            return .regular
        }
    }
}

#else
import UIKit

extension UIFont {
    
    
    static func createFrom(from properties: FontProperties) -> UIFont {
        let size = properties.scaledSize
        let weight = properties.weight.uiKitWeight
        
        switch properties.family {
        case .system(let design):
            let font: UIFont
            switch design {
            case .default:
                font = UIFont.systemFont(ofSize: size, weight: weight)
            case .serif:
                font = UIFont.systemFont(ofSize: size, weight: weight)
            case .rounded:
                font = UIFont.systemFont(ofSize: size, weight: weight)
                
            case .monospaced:
                font = UIFont.monospacedSystemFont(ofSize: size, weight: weight)
            @unknown default:
                font = UIFont.systemFont(ofSize: size, weight: weight)
            }
            return font.applyVariants(properties: properties)
        case .custom(let name):
            guard let font = UIFont(name: name, size: size) else {
                fatalError("Failed to create UIFont for custom font name '\(name)'")
            }
            return font.applyVariants(properties: properties)
        }
    }
    
    func applyVariants(properties: FontProperties) -> UIFont {
        var fd: UIFontDescriptor = self.fontDescriptor
        
        switch properties.family {
        case .system(let design):
            switch design {
            case .default:
                break;
            case .serif:
                fd = fd.withDesign(.serif) ?? fd
            case .rounded:
                fd = fd.withDesign(.rounded) ?? fd
            case .monospaced:
                fd = fd.withDesign(.monospaced) ?? fd
            @unknown default:
                break
            }
        case .custom(let name):
            break
        }
        
        var traits: UIFontDescriptor.SymbolicTraits = fd.symbolicTraits
        var fontFeatures: [[UIFontDescriptor.FeatureKey: Int]] = []
        
        
        switch properties.familyVariant {
        case .normal:
            break
        case .monospaced:
            traits.insert(.traitMonoSpace)
        }
        
        switch properties.style {
        case .normal:
            break
        case .italic:
            traits.insert(.traitItalic)
        }
        
        
        switch properties.capsVariant {
        case .normal:
            break
        case .smallCaps:
            fontFeatures.append([
                  .type: kLetterCaseType,
                  .selector: kSmallCapsSelector
                ])
        case .lowercaseSmallCaps:
            fontFeatures.append([
                  .type: kLowerCaseType,
                  .selector: kLowerCaseSmallCapsSelector
                ])
        case .uppercaseSmallCaps:
            fontFeatures.append([
                  .type: kUpperCaseType,
                  .selector: kUpperCaseSmallCapsSelector
                ])
        }
        switch properties.digitVariant {
        case .normal:
            break
        case .monospaced:
            traits.insert(.traitMonoSpace)
        }
        
        var descriptor = self.fontDescriptor.withSymbolicTraits(traits)
        descriptor = (descriptor ?? self.fontDescriptor)
            .addingAttributes([.featureSettings: fontFeatures])
        
        
        return UIFont(descriptor: (descriptor ?? self.fontDescriptor), size: properties.scaledSize)
    }
    
}


private extension Font.Weight {
    var uiKitWeight: UIFont.Weight {
        switch self {
        case .ultraLight:
            return .ultraLight
        case .thin:
            return .thin
        case .light:
            return .light
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        case .heavy:
            return .heavy
        case .black:
            return .black
        default:
            print("Self Font Weight: \(self)")
            return .regular
        }
    }
}





#endif
