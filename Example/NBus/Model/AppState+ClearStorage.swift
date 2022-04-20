//
//  AppState+ClearStorage.swift
//  BusMock
//
//  Created by nuomi1 on 2022/4/1.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
import UIKit

extension AppState {

    func clearKeychains() {
        let items = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity,
        ]

        let status = items
            .map { [kSecClass: $0] as CFDictionary }
            .map { SecItemDelete($0) }

        assert(status.allSatisfy {
            $0 == errSecSuccess || $0 == errSecItemNotFound
        })
    }

    func clearPasteboard(shouldSetString: Bool = false) {
        let pasteboard = UIPasteboard.general

        pasteboard.items = []

        if shouldSetString {
            pasteboard.string = Self.defaultPasteboardString
        }
    }

    func clearUserDefaults() {
        let defaults = UserDefaults.standard

        for (key, _) in defaults.dictionaryRepresentation() {
            defaults.removeObject(forKey: key)
        }
    }

    func setAgainPasteboard() {
        let pasteboard = UIPasteboard.general

        let items = pasteboard.items

        pasteboard.items = []
        pasteboard.items = items
    }
}
