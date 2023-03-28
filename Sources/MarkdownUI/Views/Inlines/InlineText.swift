import SwiftUI

struct InlineText: View {
  @Environment(\.inlineImageProvider) private var inlineImageProvider
    @Environment(\.linkAttributeAugmenter) private var linkAttributeAugmenter
  @Environment(\.baseURL) private var baseURL
  @Environment(\.imageBaseURL) private var imageBaseURL
  @Environment(\.theme) private var theme
    @Environment(\.attributedTextActionHandler) private var attributedTextActionHandler
    @Environment(\.substringHighlightRegex) private var substringHighlightRegex: String?
    
    @Environment(\.richTextSelectability) private var richTextSelectability: Bool
    
  @State private var inlineImages: [String: Image] = [:]

  private let inlines: [InlineNode]

  init(_ inlines: [InlineNode]) {
    self.inlines = inlines
  }

  var body: some View {
    TextStyleAttributesReader { attributes in
        #if os(macOS)
        TextFieldAppKit(
            inlines: self.inlines,
            images: self.inlineImages,
            environment: .init(
              baseURL: self.baseURL,
              code: self.theme.code,
              emphasis: self.theme.emphasis,
              strong: self.theme.strong,
              strikethrough: self.theme.strikethrough,
              link: self.theme.link,
              highlighted: self.theme.highlighted
            ),
            attributes: attributes,
            linkAugmenter: linkAttributeAugmenter,
            substringHighlightRegex: substringHighlightRegex,
            attributedTextActionHandler: attributedTextActionHandler
        )
        #else
//        TextLabelUIKit(inlines: self.inlines,
//                       images: self.inlineImages,
//                       environment: .init(
//                         baseURL: self.baseURL,
//                         code: self.theme.code,
//                         emphasis: self.theme.emphasis,
//                         strong: self.theme.strong,
//                         strikethrough: self.theme.strikethrough,
//                         link: self.theme.link
//                       ),
//                       attributes: attributes,
//                       linkAugmenter: linkAttributeAugmenter)
        
      Text(
        inlines: self.inlines,
        images: self.inlineImages,
        environment: .init(
          baseURL: self.baseURL,
          code: self.theme.code,
          emphasis: self.theme.emphasis,
          strong: self.theme.strong,
          strikethrough: self.theme.strikethrough,
          link: self.theme.link,
          highlighted: self.theme.highlighted
        ),
        images: self.inlineImages,
        attributes: attributes,
        linkAugmenter: linkAttributeAugmenter,
        substringHighlightRegex: substringHighlightRegex
      )
        
        #endif
    }
    .task(id: self.inlines, priority: .medium) {
      self.inlineImages = (try? await self.loadInlineImages()) ?? [:]
    }
    .fixedSize(horizontal: false, vertical: true)
  }

  private func loadInlineImages() async throws -> [String: Image] {
    let images = Set(self.inlines.compactMap(\.imageData))
    guard !images.isEmpty else { return [:] }

    return try await withThrowingTaskGroup(of: (String, Image).self) { taskGroup in
      for image in images {
        guard let url = URL(string: image.source, relativeTo: self.imageBaseURL) else {
          continue
        }

        taskGroup.addTask {
          (image.source, try await self.inlineImageProvider.image(with: url, label: image.alt))
        }
      }

      var inlineImages: [String: Image] = [:]

      for try await result in taskGroup {
        inlineImages[result.0] = result.1
      }

      return inlineImages
    }
  }
}
