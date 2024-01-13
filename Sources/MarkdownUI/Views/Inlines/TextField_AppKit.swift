//
//  File.swift
//  
//
//  Created by Ryan Mckinney on 3/10/23.
//
#if os(macOS)
import Foundation

import SwiftUI
import AppKit
import AttributedString


struct TextFieldAppKit: View {
    
    let attributed: ASAttributedString
    @Environment(\.textActionObservers) var textActionObservers
    @Environment(\.richTextSelectability) private var richTextSelectability: Bool

    init(baseURL: URL?,
         inlines: [InlineNode],
         images: [String: Image],
         textStyles: InlineTextStyles,
         attributes: AttributeContainer,
         symAugmented: SymAugmentation
    ) {
//        attributed = .createFrom(baseURL: baseURL,
//                                 inlines: inlines,
//                                 images: images,
//                                 textStyles: textStyles,
//                                 attributes: attributes,
//                                 symAugmented: symAugmented
//        )
        attributed = .createFromArray(baseURL: baseURL,
                                 inlines: inlines,
                                 textStyles: textStyles,
                                 attributes: attributes,
                                      sym: symAugmented
        )
    }
    
    var body: some View {
        HuggingNSTextFieldRep(attributedString: nil,
                              attr: attributed,
                              textActionObservers: textActionObservers,
                              textIsSelectable: richTextSelectability)
            .fixedSize(horizontal: false, vertical: true)
//            .frame(minWidth: 60, alignment: .leading)
    }
}




struct HuggingNSTextFieldRep: NSViewRepresentable {
  typealias NSViewType = HuggingNSTextField

    let attributedString: NSAttributedString?
    let attr: ASAttributedString?
    let textActionObservers: [TextActionObserver]
    let textIsSelectable: Bool
    
    func makeNSView(context: Context) -> HuggingNSTextField {
        let view: HuggingNSTextField = HuggingNSTextField()
        // set background color to show view bounds
//        view.attributed.string = attr

        view.backgroundColor = .clear
        view.drawsBackground = false
        view.isBezeled = false
        view.isEditable = false
        view.allowsEditingTextAttributes = true
        view.isSelectable = textIsSelectable
        view.lineBreakMode = .byWordWrapping
        view.maximumNumberOfLines = 0
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)

        if let attr = self.attr {
            view.attributed.string = attr
        } else if let attrStr = self.attributedString {
            view.attributedStringValue = attrStr
        }
        
        for actionObs in textActionObservers {
            view.attributed.observe(actionObs.checkings, highlights: actionObs.highlights) { (result) in
                actionObs.callback(result)
            }
        }
        
//        view.attributedStringValue = text
//        view.sizeToFit()
        
        
        return view
  }

  func updateNSView(_ nsView: HuggingNSTextField, context: Context) {
      if let attr = self.attr,
            nsView.attributed.string != attr {
//          print("TextField_AppKit updateNSView")
          nsView.attributed.string = attr
//          nsView.sizeToFit()
      } else if let attrStr = self.attributedString,
                    nsView.attributedStringValue != attrStr {
          nsView.attributedStringValue = attrStr
//          nsView.sizeToFit()
      }
      
  }
    
    
}


class HuggingNSTextField: NSTextField {
    
//    override func resetCursorRects() {
//        let attributedString = self.attributedStringValue
//
//        attributedString.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedString.length)) { (url, range, _) in
//            if let _ = url as? URL {
//                self.addCursorRect(self.bounds, cursor: .pointingHand)
//                return
//            }
//        }
//    }
//
//    override func mouseDown(with event: NSEvent) {
//        let location = convert(event.locationInWindow, from: nil)
//
//
//
//        let characterIndex = layoutManager?.characterIndex(for: location, in: textContainer!, fractionOfDistanceBetweenInsertionPoints: nil)
//
//        if let url = attributedStringValue.attribute(.link, at: characterIndex!, effectiveRange: nil) as? URL {
//            NSWorkspace.shared.open(url)
//        } else {
//            super.mouseDown(with: event)
//        }
//    }

}



#endif