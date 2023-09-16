//
//  File.swift
//  
//
//  Created by Ryan Mckinney on 3/13/23.
//
#if os(iOS)
import Foundation
import SwiftUI
import UIKit
import AttributedString

struct TextLabelUIKit: View {

    let attributed: ASAttributedString
    init(baseURL: URL?,
         inlines: [InlineNode],
         images: [String: Image],
         textStyles: InlineTextStyles,
         attributes: AttributeContainer,
         symAugmented: SymAugmentation
    ) {
        attributed = .createFrom(baseURL: baseURL,
                                 inlines: inlines,
                                 images: images,
                                 textStyles: textStyles,
                                 attributes: attributes,
                                 symAugmented: symAugmented
        )
    }
    
    var body: some View {
//        UILabelViewRep(attr: attributed)
//            .fixedSize(horizontal: false, vertical: true)
//            .frame(minWidth: 60, alignment: .leading)

        HorizontalGeometryReader { width in
            UILabelViewRep(attr: attributed,
                           preferredMaxLayoutWidth: width
            )
            .frame(minWidth: 60, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
    
}

struct UILabelViewRep: UIViewRepresentable {
    
    let attr: ASAttributedString
    var preferredMaxLayoutWidth: CGFloat = .greatestFiniteMagnitude

    public func makeUIView(context: Context) -> HuggingUILabel {
        let label = HuggingUILabel(frame: .zero)
        label.numberOfLines = 0
//        label.lineBreakMode = .byWordWrapping
//        label.lineBreakStrategy = .standard
//        label.isEnabled = true
        
        //FOR horizontal geometry readyer wrapped
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)

        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
//        label.setContentHuggingPriority(.defaultLow, for: .vertical)


        //similar to mac version
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
//
//        label.setContentCompressionResistancePriority(.required, for: .vertical)
//        label.setContentHuggingPriority(.defaultLow, for: .vertical)

//        label.attributedText = attr.value
        label.attributed.text = attr
        label.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        
//        label.sizeToFit()
        
        
        return label
    }

    public func updateUIView(_ uiView: HuggingUILabel, context: Context) {
        print("TextLabel_UIKit updateUIView: \(self.attr.value.string) intrinsicContentSize: \(uiView.intrinsicContentSize)")
        
        if attr != uiView.attributed.text {
            uiView.attributed.text = attr
        }
        if uiView.preferredMaxLayoutWidth != preferredMaxLayoutWidth {
            uiView.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        }
        
    }
}

class HuggingUILabel: UILabel {
    
}


fileprivate struct HorizontalGeometryReader<Content: View> : View {
    var content: (CGFloat) -> Content
    @State private var width: CGFloat = 0

    public init(@ViewBuilder content: @escaping (CGFloat) -> Content) {
        self.content = content
    }

    public var body: some View {
        content(width)
//            .frame(minWidth: 0, maxWidth: .greatestFiniteMagnitude)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: WidthPreferenceKey.self, value: geometry.size.width)
                }
            )
            .onPreferenceChange(WidthPreferenceKey.self) { width in
                self.width = width
            }
    }
}

fileprivate struct WidthPreferenceKey: PreferenceKey, Equatable {
    static var defaultValue: CGFloat = 0

    /// An empty reduce implementation takes the first value
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    }
}


#endif
