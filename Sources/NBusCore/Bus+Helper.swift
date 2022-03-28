//
//  Bus+Helper.swift
//  NBus
//
//  Created by nuomi1 on 2020/9/8.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import CommonCrypto
import Foundation
import UIKit

extension Dictionary: BusCompatible {}

extension BusWrapper where Base == [Bus.OauthInfoKey: String?] {

    public func compactMapContent() -> [Bus.OauthInfoKey: String] {
        base.compactMapValues { value -> String? in
            guard
                let value = value, !value.isEmpty
            else {
                return nil
            }

            return value
        }
    }
}

extension String: BusCompatible {}

extension BusWrapper where Base == String {

    public var base64EncodedString: String {
        let data = Data(base.utf8)

        return data.base64EncodedString()
    }

    public var sha1: String {
        let data = Data(base.utf8)

        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes { pointer in
            _ = CC_SHA1(pointer.baseAddress, CC_LONG(data.count), &digest)
        }

        let bytes = digest.map { String(format: "%02hhx", $0) }
        return bytes.joined()
    }
}

extension URLComponents: BusCompatible {}

extension BusWrapper where Base == URLComponents {

    public func mergingQueryItems(_ other: [String: String?]) -> [URLQueryItem]? {
        let oldItems = base.queryItems ?? []
        let newItems = other.map { URLQueryItem(name: $0, value: $1) }

        let items = newItems + oldItems

        var foundNames: Set<String> = []

        let queryItems = items.filter {
            $0.value != nil && foundNames.insert($0.name).inserted
        }

        return queryItems.isEmpty ? nil : queryItems
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

extension BusWrapper where Base: UIDevice {

    private var systemInfo: utsname {
        var systemInfo = utsname()
        uname(&systemInfo)
        return systemInfo
    }

    private func toString(from mirror: Mirror) -> String {
        let cString = mirror.children.compactMap { $1 as? Int8 }
        return String(cString: cString)
    }

    public var machine: String {
        let mirror = Mirror(reflecting: systemInfo.machine)
        return toString(from: mirror)
    }
}

extension BusWrapper where Base: UIPasteboard {

    public var oldText: String? {
        guard
            let typeListString = UIPasteboard.typeListString as? [String]
        else {
            busAssertionFailure()
            return nil
        }

        guard
            base.contains(pasteboardTypes: typeListString)
        else {
            return nil
        }

        return base.string
    }
}
