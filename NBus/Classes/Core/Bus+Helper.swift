//
//  Bus+Helper.swift
//  NBus
//
//  Created by nuomi1 on 2020/9/8.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation

extension Dictionary: BusCompatible {}

extension BusWrapper where Base == [Bus.OauthInfoKey: String?] {

    public func compactMapContent() -> [Bus.OauthInfoKey: String] {
        base.compactMapValues { value -> String? in
            guard
                let value = value, !value.isEmpty
            else { return nil }

            return value
        }
    }
}

extension String: BusCompatible {}

extension BusWrapper where Base == String {

    var base64EncodedString: String? {
        base.data(using: .utf8)?.base64EncodedString()
    }
}

extension NSObject: BusCompatible {}

extension BusWrapper where Base: Bundle {

    private func value<T>(forKeys keys: [String]) -> T? {
        let infos = [
            base.localizedInfoDictionary ?? [:],
            base.infoDictionary ?? [:],
        ]

        for key in keys {
            for info in infos {
                if let value = info[key] as? T {
                    return value
                }
            }
        }

        return nil
    }

    public var identifier: String? {
        value(forKeys: ["CFBundleIdentifier"])
    }

    public var displayName: String? {
        value(forKeys: ["CFBundleDisplayName", "CFBundleName"])
    }
}

extension BusWrapper where Base: UIPasteboard {

    public var oldText: String? {
        guard
            let typeListString = UIPasteboard.typeListString as? [String]
        else {
            assertionFailure()
            return nil
        }

        guard base.contains(pasteboardTypes: typeListString) else { return nil }

        return base.string
    }
}
