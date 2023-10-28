import Foundation
import SwiftUI


enum FontPropertiesAttribute: AttributedStringKey {
  typealias Value = FontProperties
  static let name = "fontProperties"
}

extension AttributeScopes {
  var markdownUI: MarkdownUIAttributes.Type {
    MarkdownUIAttributes.self
  }

  struct MarkdownUIAttributes: AttributeScope {
    let swiftUI: SwiftUIAttributes
    let fontProperties: FontPropertiesAttribute
  }
}

extension AttributeDynamicLookup {
  subscript<T: AttributedStringKey>(
    dynamicMember keyPath: KeyPath<AttributeScopes.MarkdownUIAttributes, T>
  ) -> T {
    return self[T.self]
  }
}

extension AttributedString {
  func resolvingFonts() -> AttributedString {
    var output = self

    for run in output.runs {
      guard let fontProperties = run.fontProperties else {
        continue
      }
        output[run.range].swiftUI.font = .withProperties(fontProperties)
        #if os(macOS)
        output[run.range].appKit.font = .createFrom(from: fontProperties)
        #elseif os(iOS)
        output[run.range].uiKit.font = .createFrom(from: fontProperties)
        #endif
      output[run.range].fontProperties = nil
    }
    return output
  }
    
    func highlightMatches(
        regex: String?,
        attributes: AttributeContainer? = nil,
        fallbackBgColor: Color = Color.yellow
    ) -> AttributedString {
        guard let regexStr = regex else { return self }
        guard let nRegex = try? NSRegularExpression(pattern: regexStr, options: .caseInsensitive) else {
            return self
        }

        let selfString = String(self.characters[...])
        var copy = self
        
        let range = NSRange(self.startIndex..<self.endIndex, in: self)
        let matches = nRegex.matches(in: selfString, range: range)
        for match in matches {
            if let range = Range(match.range, in: self) {
                if let expAttributes = attributes {
                    copy[range].mergeAttributes(expAttributes, mergePolicy: .keepNew)
                } else {
                    copy[range].backgroundColor = fallbackBgColor
                }
            }
            
        }
        return copy
    }
}
