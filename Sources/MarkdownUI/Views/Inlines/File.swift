//
//  File.swift
//  
//
//  Created by Ryan Mckinney on 5/3/23.
//

import Foundation



//@propertyWrapper
//struct ProfileExecution<T> {
//    private let function: () -> T
//    private(set) var executionTime: TimeInterval?
//
//    init(_ function: @escaping () -> T) {
//        self.function = function
//    }
//
//    var wrappedValue: T {
//        get {
//            return profileFunction()
//        }
//    }
//
//    private mutating func profileFunction() -> T {
//        let startTime = CFAbsoluteTimeGetCurrent()
//        let result = function()
//        let endTime = CFAbsoluteTimeGetCurrent()
//        executionTime = endTime - startTime
//        return result
//    }
//
//    var projectedValue: TimeInterval? {
//        return executionTime
//    }
//}
