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





struct OnTextTapCallbackEnabledKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

struct OnTextTapCallbackKey: EnvironmentKey {
    static let defaultValue: TextTapCallbacks? = nil
}


public extension EnvironmentValues {
    var mdOnTextTapEnabled_iOS: Bool {
        get { self[OnTextTapCallbackEnabledKey.self] }
        set { self[OnTextTapCallbackEnabledKey.self] = newValue }
    }
    
    var mdOnTextTapCb_iOS: TextTapCallbacks? {
        get { self[OnTextTapCallbackKey.self] }
        set { self[OnTextTapCallbackKey.self] = newValue }
    }
}

public extension View {
    func setMdOnTextTapEnabled_iOS(_ enabled: Bool) -> some View {
        self
            .environment(\.mdOnTextTapEnabled_iOS, enabled)
    }
    
    func setMdOnTextTapCb_iOS(_ cb: TextTapCallbacks?) -> some View {
        self
            .environment(\.mdOnTextTapCb_iOS, cb)
    }
}


