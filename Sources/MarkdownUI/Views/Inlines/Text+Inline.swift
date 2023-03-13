import SwiftUI

extension Text {
  init(
    inlines: [Inline],
    images: [String: Image],
    environment: InlineEnvironment,
    attributes: AttributeContainer,
    linkAugmenter: LinkAttributeAugmenter,
    substringHighlightRegex: String?
  ) {
    self = inlines.map { inline in
        Text(inline: inline, images: images, environment: environment, attributes: attributes, linkAugmenter: linkAugmenter, substringHighlightRegex: substringHighlightRegex)
    }
    .reduce(.init(""), +)
  }

  init(
    inline: Inline,
    images: [String: Image],
    environment: InlineEnvironment,
    attributes: AttributeContainer,
    linkAugmenter: LinkAttributeAugmenter,
    substringHighlightRegex: String?
  ) {
    switch inline {
    case .image(let source, _):
      if let image = images[source] {
        self.init(image)
      } else {
        self.init("")
      }
    default:
      self.init(
        AttributedString(inline: inline,
                         environment: environment,
                         attributes: attributes,
                         linkAugmenter: linkAugmenter)
          .resolvingFonts()
          .highlightMatches(regex: substringHighlightRegex, attributes: environment.highlighted.mergingAttributes(attributes))
        
        //https://augmentedcode.io/2021/06/21/exploring-attributedstring-and-custom-attributes/
        //custom hook here to transform the attributed string
      )
    }
  }
}
