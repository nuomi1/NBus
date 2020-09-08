//
//  Bus+Helper.swift
//  NBus
//
//  Created by nuomi1 on 2020/9/8.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation

extension Dictionary where Key == Bus.OauthInfoKey, Value == String? {

    func compactMapContent() -> [Bus.OauthInfoKey: String] {
        compactMapValues { value -> String? in
            guard
                let value = value, !value.isEmpty
            else { return nil }

            return value
        }
    }
}
