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


public typealias OnTextTapCallback = () -> Void


struct OnTextTapCallbackKey: EnvironmentKey {
    static let defaultValue: OnTextTapCallback? = nil
}


public extension EnvironmentValues {
    var mdOnTextTapCb_iOS: OnTextTapCallback? {
        get { self[OnTextTapCallbackKey.self] }
        set { self[OnTextTapCallbackKey.self] = newValue }
    }
}

public extension View {
    
    func setMdOnTextTapCb_iOS(_ cb: OnTextTapCallback?) -> some View {
        self
            .environment(\.mdOnTextTapCb_iOS, cb)
    }
}


