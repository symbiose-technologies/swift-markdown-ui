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

public struct StringTransformation  {
    public let target: String
    public let caseSensitive: Bool
    public let replacementBuilder: (String) -> String

    public init(target: String, caseSensitive: Bool, replacementBuilder: @escaping (String) -> String) {
        self.target = target
        self.caseSensitive = caseSensitive
        self.replacementBuilder = replacementBuilder
    }
}

public extension String {
    
    
    func transformWith(using transformations: [StringTransformation]) -> (String, Bool) {
        var modifiedText = self
        var didTransform = false

        for transformation in transformations {
            let options: String.CompareOptions = transformation.caseSensitive ? [] : [.caseInsensitive]

            if let range = modifiedText.range(of: transformation.target, options: options) {
                didTransform = true
                let detectedMatch = String(modifiedText[range])
                let replacement = transformation.replacementBuilder(detectedMatch)
                modifiedText = modifiedText.replacingCharacters(in: range, with: replacement)
            }
        }

        return (modifiedText, didTransform)
    }

    
}


// Example:
//let transformations: [Transformation] = [
//    Transformation(target: "hello", caseSensitive: false) { match in
//        return match.uppercased()
//    },
//    Transformation(target: "world", caseSensitive: true) { match in
//        return "🌎"
//    }
//]
//
//let result = transform(text: "Hello, world!", using: transformations)
//print(result)  // ("HELLO, 🌎!", true)
