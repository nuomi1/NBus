//
//  Bus+Wrapper.swift
//  NBus
//
//  Created by nuomi1 on 2021/1/4.
//  Copyright © 2021 nuomi1. All rights reserved.
//

import Foundation

public struct BusWrapper<Base> {

    public let base: Base

    public init(_ base: Base) {
        self.base = base
    }
}

public protocol BusCompatible {

    associatedtype BusBase

    var bus: BusWrapper<BusBase> { get }
}

extension BusCompatible {

    public var bus: BusWrapper<Self> {
        BusWrapper(self)
    }
}

@propertyWrapper
public struct BusUserDefaults<T> {

    public let userDefaults: UserDefaults

    public let key: String

    public var wrappedValue: T? {
        get { userDefaults.object(forKey: key) as? T }
        set { userDefaults.set(newValue, forKey: key) }
    }

    public init(
        key: String,
        userDefaults: UserDefaults = .standard
    ) {
        self.key = key
        self.userDefaults = userDefaults
    }
}

extension BusUserDefaults {

    public init<U>(
        key: U,
        userDefaults: UserDefaults = .standard
    ) where U: RawRepresentable, U.RawValue == String {
        self.init(key: key.rawValue, userDefaults: userDefaults)
    }
}

@propertyWrapper
public struct BusCheckURLScheme {

    public let url: URL

    public var wrappedValue: Bool {
        UIApplication.shared.canOpenURL(url)
    }

    public init(url: URL) {
        self.url = url
    }
}
