import Foundation

struct InlineEnvironment {
  let baseURL: URL?
  let code: TextStyle
  let emphasis: TextStyle
  let strong: TextStyle
  let strikethrough: TextStyle
  let link: TextStyle
  let highlighted: TextStyle
}

extension AttributedString {
    init(inlines: [Inline], environment: InlineEnvironment, attributes: AttributeContainer, linkAugmenter: LinkAttributeAugmenter) {
    self = inlines.map {
      AttributedString(inline: $0, environment: environment, attributes: attributes, linkAugmenter: linkAugmenter)
    }
    .reduce(.init(), +)
  }
//CUSTOM AttributeScope for the AttributedString to be able to take arbitrary "keys" as passed by Apple markdown custom attribute scope: https://developer.apple.com/documentation/foundation/attributedstring
    
    
    init(inline: Inline, environment: InlineEnvironment, attributes: AttributeContainer, linkAugmenter: LinkAttributeAugmenter) {
    switch inline {
    case .text(let content):
      self.init(content, attributes: attributes)
    case .softBreak:
      self.init(" ", attributes: attributes)
    case .lineBreak:
      self.init("\n", attributes: attributes)
    case .code(let content):
      self.init(content, attributes: environment.code.mergingAttributes(attributes))
    case .html(let content):
      self.init(content, attributes: attributes)
    case .emphasis(let children):
      self.init(
        inlines: children,
        environment: environment,
        attributes: environment.emphasis.mergingAttributes(attributes),
        linkAugmenter: linkAugmenter
      )
    case .strong(let children):
      self.init(
        inlines: children,
        environment: environment,
        attributes: environment.strong.mergingAttributes(attributes),
        linkAugmenter: linkAugmenter
      )
    case .strikethrough(let children):
      self.init(
        inlines: children,
        environment: environment,
        attributes: environment.strikethrough.mergingAttributes(attributes),
        linkAugmenter: linkAugmenter
      )
    case .link(let destination, let children):
        //TODO -- parse the link and optionally provide a transformation so that custom entitities can render as we please
      var newAttributes = environment.link.mergingAttributes(attributes)
      newAttributes.link = URL(string: destination, relativeTo: environment.baseURL)
        newAttributes = linkAugmenter.augmentLinkAttributes(
            sourceAttributes: newAttributes,
            url: newAttributes.link,
            childrenText: children.text)

        self.init(inlines: children,
                  environment: environment,
                  attributes: newAttributes,
                  linkAugmenter: linkAugmenter)
    case .image:
      // AttributedString does not support images
      self.init()
    }
  }
}

extension TextStyle {
  func mergingAttributes(_ attributes: AttributeContainer) -> AttributeContainer {
    var newAttributes = attributes
    self._collectAttributes(in: &newAttributes)
    return newAttributes
  }
}
