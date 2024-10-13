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
    
    @Environment(\.textActionObservers) var textActionObservers
    @Environment(\.richTextSelectability) private var richTextSelectability: Bool
    
    let attributed: ASAttributedString
    init(baseURL: URL?,
         inlines: [InlineNode],
         images: [String: Image],
         textStyles: InlineTextStyles,
         softBreakMode: SoftBreak.Mode,
         attributes: AttributeContainer,
         symAugmented: SymAugmentation
    ) {
        attributed = .createFromArray(baseURL: baseURL,
                                 inlines: inlines,
                                 textStyles: textStyles,
                                      softBreakMode: softBreakMode,
                                 attributes: attributes,
                                      sym: symAugmented
        )
        
    }
    
    var body: some View {
        UILabelViewRep(attr: attributed,
                       textActionObservers: textActionObservers,
                       textIsSelectable: richTextSelectability)
            .fixedSize(horizontal: false, vertical: true)

    }
    
}

struct UILabelViewRep: UIViewRepresentable {
    
    let attr: ASAttributedString
    
    let textActionObservers: [TextActionObserver]
    let textIsSelectable: Bool
    
    
    var preferredMaxLayoutWidth: CGFloat = UIScreen.main.bounds.width

    
    public func makeUIView(context: Context) -> HuggingUILabel {
//        let label = HuggingUILabel()
//        label.numberOfLines = 0
//        //        label.lineBreakMode = .byWordWrapping
//        //        label.lineBreakStrategy = .standard
//        //        label.isEnabled = true
//        
//        //FOR horizontal geometry readyer wrapped
//        //        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        //        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        
//        label.setContentHuggingPriority(.required, for: .horizontal)
//        //        label.setContentHuggingPriority(.required, for: .horizontal)
//        label.setContentHuggingPriority(.required, for: .vertical)
//        
//        //        label.setContentCompressionResistancePriority(.required, for: .vertical)
//        //        label.setContentHuggingPriority(.required, for: .vertical)
//        
//        
//        //        label.translatesAutoresizingMaskIntoConstraints = false
//        //        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        //        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        //        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
//        //        label.setContentHuggingPriority(.defaultLow, for: .vertical)
//        
//        
//        //similar to mac version
//        //        label.translatesAutoresizingMaskIntoConstraints = false
//        //        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        //        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        //
//        //        label.setContentCompressionResistancePriority(.required, for: .vertical)
//        //        label.setContentHuggingPriority(.defaultLow, for: .vertical)
//        
//        //        label.attributedText = attr.value
//        label.attributed.text = attr
//        label.preferredMaxLayoutWidth = preferredMaxLayoutWidth
//        
//        return label
        
        let label = HuggingUILabel()
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        
//        label.setContentHuggingPriority(.required, for: .vertical)
//        label.setContentCompressionResistancePriority(.required, for: .vertical)
//        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        
        label.attributed.text = attr
        label.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        
        
        for actionObs in textActionObservers {
            label.attributed.observe(actionObs.checkings, highlights: actionObs.highlights) { (result) in
                actionObs.callback(result)
            }
        }
        
        
        
        return label
    }

    public func updateUIView(_ uiView: HuggingUILabel, context: Context) {
//        print("TextLabel_UIKit updateUIView: \(self.attr.value.string) intrinsicContentSize: \(uiView.intrinsicContentSize)")
        var didChange = false
        if attr != uiView.attributed.text {
            uiView.attributed.text = attr
            didChange = true
        }
        if uiView.preferredMaxLayoutWidth != preferredMaxLayoutWidth {
            uiView.preferredMaxLayoutWidth = preferredMaxLayoutWidth
            didChange = true
        }
        
        if didChange {
            uiView.invalidateIntrinsicContentSize()
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
