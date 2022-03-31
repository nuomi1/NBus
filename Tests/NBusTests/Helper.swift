//
//  Helper.swift
//  BusTests
//
//  Created by nuomi1 on 2022/3/30.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation

extension Array {

    mutating func removeFirst(where shouldBeRemoved: (Element) throws -> Bool) rethrows -> Element? {
        guard let index = try firstIndex(where: shouldBeRemoved) else { return nil }
        return remove(at: index)
    }
}
