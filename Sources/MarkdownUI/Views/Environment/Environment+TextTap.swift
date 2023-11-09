//////////////////////////////////////////////////////////////////////////////////
//
//  SYMBIOSE
//  Copyright 2023 Symbiose Technologies, Inc
//  All Rights Reserved.
//
//  NOTICE: This software is proprietary information.
//  Unauthorized use is prohibited.
//
// 
// Created by: Ryan Mckinney on 10/24/23
//
////////////////////////////////////////////////////////////////////////////////

import Foundation
import SwiftUI


public typealias OnTextTapCallback = ([InlineNode]) -> Void
public struct TextTapCallbacks {
    let singleTap: OnTextTapCallback?
    let doubleTap: OnTextTapCallback?
    public init(singleTap: OnTextTapCallback?, doubleTap: OnTextTapCallback?) {
        self.singleTap = singleTap
        self.doubleTap = doubleTap
    }
}





struct OnTextTapCallbackKey: EnvironmentKey {
    static let defaultValue: TextTapCallbacks? = nil
}


public extension EnvironmentValues {
    var mdOnTextTapCb_iOS: TextTapCallbacks? {
        get { self[OnTextTapCallbackKey.self] }
        set { self[OnTextTapCallbackKey.self] = newValue }
    }
}

public extension View {
    
    func setMdOnTextTapCb_iOS(_ cb: TextTapCallbacks?) -> some View {
        self
            .environment(\.mdOnTextTapCb_iOS, cb)
    }
}


