import Foundation

extension InlineNode {
  func renderAttributedString(
    baseURL: URL?,
    textStyles: InlineTextStyles,
    attributes: AttributeContainer,
    symAugmented: SymAugmentation
  ) -> AttributedString {
    var renderer = AttributedStringInlineRenderer(
      baseURL: baseURL,
      textStyles: textStyles,
      attributes: attributes,
      symAugmented: symAugmented
    )
    renderer.render(self)
    return renderer.result
          .resolvingFonts()
          .highlightMatches(regex: symAugmented.highlightSubstringRegex,
                            attributes: symAugmented.highlightedStyle.mergingAttributes(renderer.attributes))
  }
}

//create a version that takes an array of `[InlineNode]` and uses a reduce fn to create a single attributed string

extension Array where Element == InlineNode {
    func renderCombinedAttributedString(
        baseURL: URL?,
        textStyles: InlineTextStyles,
        attributes: AttributeContainer,
        symAugmented: SymAugmentation,
        executeHighlightRegex: Bool = false
    ) -> AttributedString {
        
        if let cached = SymAttributedStringCache.shared.attrStrCache.value(forKey: .init(
            inlineNodes: self,
            attributes: attributes)) {
//            print("[ATTRIBUTED STRING] CACHE HIT!!")
            if executeHighlightRegex {
                return cached
                    .highlightMatches(
                        regex: symAugmented.highlightSubstringRegex,
                        attributes: symAugmented.highlightedStyle.mergingAttributes(attributes)
                    )
            } else {
                return cached
            }
            
            
        } else {
            let combinedAttributedString = reduce(into: AttributedString()) { result, node in
                let nodeAttributedString = node.renderAttributedString(
                    baseURL: baseURL,
                    textStyles: textStyles,
                    attributes: attributes,
                    symAugmented: symAugmented
                )
                result.append(nodeAttributedString)
            }
            
            let cacheableStr = combinedAttributedString
                .resolvingFonts()
            
            SymAttributedStringCache.shared.attrStrCache.insert(cacheableStr, forKey: .init(inlineNodes: self, attributes: attributes))
            
            if executeHighlightRegex {
                return cacheableStr
                    .highlightMatches(
                        regex: symAugmented.highlightSubstringRegex,
                        attributes: symAugmented.highlightedStyle.mergingAttributes(attributes)
                    )
            } else {
                return cacheableStr
            }
        }
        
        
    }
}



private struct AttributedStringInlineRenderer {
  var result = AttributedString()

  private let baseURL: URL?
  private let textStyles: InlineTextStyles
  private(set) var attributes: AttributeContainer
  private var shouldSkipNextWhitespace = false

    let symAugmentation: SymAugmentation
    
  init(baseURL: URL?, textStyles: InlineTextStyles,
       attributes: AttributeContainer,
       symAugmented: SymAugmentation) {
      self.baseURL = baseURL
      self.textStyles = textStyles
      self.attributes = attributes
      self.symAugmentation = symAugmented
  }

  mutating func render(_ inline: InlineNode) {
    switch inline {
    case .text(let content):
      self.renderText(content)
    case .softBreak:
      self.renderSoftBreak()
    case .lineBreak:
      self.renderLineBreak()
    case .code(let content):
      self.renderCode(content)
    case .html(let content):
      self.renderHTML(content)
    case .emphasis(let children):
      self.renderEmphasis(children: children)
    case .strong(let children):
      self.renderStrong(children: children)
    case .strikethrough(let children):
      self.renderStrikethrough(children: children)
    case .link(let destination, let children):
      self.renderLink(destination: destination, children: children)
    case .image(let source, let children):
      self.renderImage(source: source, children: children)
    }
  }

  private mutating func renderText(_ text: String) {
    var text = text

    if self.shouldSkipNextWhitespace {
      self.shouldSkipNextWhitespace = false
      text = text.replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
    }

    self.result += .init(text, attributes: self.attributes)
  }

  private mutating func renderSoftBreak() {
    if self.shouldSkipNextWhitespace {
      self.shouldSkipNextWhitespace = false
    } else {
      self.result += .init(" ", attributes: self.attributes)
    }
  }

  private mutating func renderLineBreak() {
    self.result += .init("\n", attributes: self.attributes)
  }

  private mutating func renderCode(_ code: String) {
    self.result += .init(code, attributes: self.textStyles.code.mergingAttributes(self.attributes))
  }

  private mutating func renderHTML(_ html: String) {
    let tag = HTMLTag(html)

    switch tag?.name.lowercased() {
    case "br":
      self.renderLineBreak()
      self.shouldSkipNextWhitespace = true
    default:
      self.renderText(html)
    }
  }

  private mutating func renderEmphasis(children: [InlineNode]) {
    let savedAttributes = self.attributes
    self.attributes = self.textStyles.emphasis.mergingAttributes(self.attributes)

    for child in children {
      self.render(child)
    }

    self.attributes = savedAttributes
  }

  private mutating func renderStrong(children: [InlineNode]) {
    let savedAttributes = self.attributes
    self.attributes = self.textStyles.strong.mergingAttributes(self.attributes)

    for child in children {
      self.render(child)
    }

    self.attributes = savedAttributes
  }

  private mutating func renderStrikethrough(children: [InlineNode]) {
    let savedAttributes = self.attributes
    self.attributes = self.textStyles.strikethrough.mergingAttributes(self.attributes)

    for child in children {
      self.render(child)
    }

    self.attributes = savedAttributes
  }

  private mutating func renderLink(destination: String, children: [InlineNode]) {
    let savedAttributes = self.attributes
      var newAttributes = self.textStyles.link.mergingAttributes(self.attributes)
      newAttributes.link  = URL(string: destination, relativeTo: self.baseURL)
      newAttributes = self.symAugmentation.linkAttributeAugmenter
          .augmentLinkAttributes(
            sourceAttributes: newAttributes,
            url: newAttributes.link,
            childrenText: children.renderPlainText())
      self.attributes = newAttributes
      
//      self.attributes = self.textStyles.link.mergingAttributes(self.attributes)
//    self.attributes.link = URL(string: destination, relativeTo: self.baseURL)

    for child in children {
      self.render(child)
    }

    self.attributes = savedAttributes
  }

  private mutating func renderImage(source: String, children: [InlineNode]) {
    // AttributedString does not support images
  }
}

extension TextStyle {
  public func mergingAttributes(_ attributes: AttributeContainer) -> AttributeContainer {
    var newAttributes = attributes
    self._collectAttributes(in: &newAttributes)
    return newAttributes
  }
}
