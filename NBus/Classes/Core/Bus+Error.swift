//
//  Bus+Error.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/23.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation

extension Bus {

    public enum Error: Swift.Error {

        case missingHandler

        case missingApplication

        case unsupportedMessage

        case invalidMessage

        case userCancelled

        case unknown
    }
}
