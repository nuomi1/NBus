//
//  Bus+Debug.swift
//  NBus
//
//  Created by nuomi1 on 2021/3/9.
//  Copyright © 2021 nuomi1. All rights reserved.
//

import Foundation

func busAssertionFailure(
    _ message: @autoclosure () -> String = String(),
    file: StaticString = #file,
    line: UInt = #line
) {
    if Bus.shared.isDebugEnabled {
        assertionFailure(message(), file: file, line: line)
    }
}
