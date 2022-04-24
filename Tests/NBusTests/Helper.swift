//
//  Helper.swift
//  BusTests
//
//  Created by nuomi1 on 2022/3/30.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
import UIKit

extension Array {

    mutating func removeFirst(where shouldBeRemoved: (Element) throws -> Bool) rethrows -> Element? {
        guard let index = try firstIndex(where: shouldBeRemoved) else { return nil }
        return remove(at: index)
    }
}

extension Array where Element == [String: Any] {

    func pasteboardString() -> String? {
        let typeListString = UIPasteboard.typeListString as! [String]

        let strings = flatMap { dictionary in
            typeListString.compactMap { key in
                dictionary[key] as? String
            }
        }

        precondition(strings.count <= 1)

        return strings.first
    }
}

struct HandlerTestContext {

    var setPasteboardString = false

    var skipPasteboard = false
    var skipCompletion = false

    var shareState: ShareState!
}

extension HandlerTestContext {

    enum ShareState {
        case requestFirst
        case signToken
        case requestSecond
        case requestThird
        case responseURLScheme
        case responseUniversalLink
        case success
        case failure
    }
}
