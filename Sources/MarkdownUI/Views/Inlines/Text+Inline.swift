import SwiftUI

extension Text {
  init(
    inlines: [Inline],
    images: [String: Image],
    environment: InlineEnvironment,
    attributes: AttributeContainer,
    linkAugmenter: LinkAttributeAugmenter
  ) {
    self = inlines.map { inline in
        Text(inline: inline, images: images, environment: environment, attributes: attributes, linkAugmenter: linkAugmenter)
    }
    .reduce(.init(""), +)
  }

  init(
    inline: Inline,
    images: [String: Image],
    environment: InlineEnvironment,
    attributes: AttributeContainer,
    linkAugmenter: LinkAttributeAugmenter
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
        AttributedString(inline: inline, environment: environment, attributes: attributes, linkAugmenter: linkAugmenter)
          .resolvingFonts()
        //https://augmentedcode.io/2021/06/21/exploring-attributedstring-and-custom-attributes/
        //custom hook here to transform the attributed string
      )
    }
  }
}
