//
//  File.swift
//  
//
//  Created by Ryan Mckinney on 3/23/23.
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif



@discardableResult
func copyTextToClipboard(txt: String) -> Bool {
    #if os(iOS)
    UIPasteboard.general.string = txt
    return true
    #elseif os(macOS)
    let pasteBoard = NSPasteboard.general
    pasteBoard.clearContents()
    let pasteSuccess = pasteBoard.writeObjects([txt as NSString])
    return pasteSuccess
    #endif
    
}
