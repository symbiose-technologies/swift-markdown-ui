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
    
    @Environment(\.mdOnTextTapCb_iOS) private var onTextTapCb_iOS
    
  private let inlines: [InlineNode]

    var hasOnTapCb: Bool { onTextTapCb_iOS?.singleTap != nil }
    
    
  init(_ inlines: [InlineNode]) {
    self.inlines = inlines
  }
    
    var symAugmented: SymAugmentation {
        return SymAugmentation(highlightedStyle: theme.highlighted,
                               highlightSubstringRegex: substringHighlightRegex,
                               linkAttributeAugmenter: linkAttributeAugmenter,
                               attributedTextActionHandlers: attributedTextActionHandler
        )
    }

  var body: some View {
    TextStyleAttributesReader { attributes in
        #if os(macOS)
        TextFieldAppKit(
            baseURL: baseURL,
            inlines: self.inlines,
            images: self.inlineImages,
            textStyles: .init(
                code: self.theme.code,
                emphasis: self.theme.emphasis,
                strong: self.theme.strong,
                strikethrough: self.theme.strikethrough,
                link: self.theme.link
              ),
            attributes: attributes,
            symAugmented: symAugmented
        )
        #else
//        TextLabelUIKit(baseURL: baseURL,
//                       inlines: self.inlines,
//                       images: self.inlineImages,
//                       textStyles: .init(
//                           code: self.theme.code,
//                           emphasis: self.theme.emphasis,
//                           strong: self.theme.strong,
//                           strikethrough: self.theme.strikethrough,
//                           link: self.theme.link
//                         ),
//                       attributes: attributes,
//                       symAugmented: symAugmented
//        )
        
      //TODO: use the SymMemoryCache if performance is challenging
        self.inlines.renderText(
          baseURL: self.baseURL,
          textStyles: .init(
            code: self.theme.code,
            emphasis: self.theme.emphasis,
            strong: self.theme.strong,
            strikethrough: self.theme.strikethrough,
            link: self.theme.link
          ),
          images: self.inlineImages,
          attributes: attributes,
          symAugmented: self.symAugmented
        )
        .gesture(
            combinedGesture,
            including: hasOnTapCb ? .all : .subviews
        )
        
#endif
    }
    .task(id: self.inlines, priority: .low) {
      self.inlineImages = (try? await self.loadInlineImages()) ?? [:]
    }
    .fixedSize(horizontal: false, vertical: true)
  }
    
    
    var combinedGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded({ _ in
                onTextTapCb_iOS?.doubleTap?(self.inlines)
            })
            .exclusively(
                before:
                    TapGesture(count: 1)
                    .onEnded({ _ in
                        onTextTapCb_iOS?.singleTap?(self.inlines)
                    })
            )
        
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
