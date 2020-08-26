//
//  AppState+InfoDictionary.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation
import NBus

extension AppState {

    static func infoDictionary() -> InfoDictionary {
        let fake = InfoDictionary(
            bundleURLSchemes: [],
            miniProgramIDs: [],
            redirectLinks: [],
            universalLinks: []
        )

        guard let infoDictionary = Bundle.main.infoDictionary else {
            return fake
        }

        do {
            let plist = try PropertyListSerialization.data(
                fromPropertyList: infoDictionary,
                format: .xml,
                options: .zero
            )
            let value = try PropertyListDecoder().decode(
                InfoDictionary.self,
                from: plist
            )

            return value
        } catch {
            return fake
        }
    }
}

extension AppState {

    static func getAppID(for platform: Platform) -> String? {
        let infos = infoDictionary()
        let item = infos.bundleURLSchemes.first(where: { $0.platform == platform.key })
        return item?.bundleURLSchemes.first
    }

    static func getMiniProgramID(for platform: Platform) -> String? {
        let infos = infoDictionary()
        let item = infos.miniProgramIDs.first(where: { $0.platform == platform.key })
        return item?.miniProgramID
    }

    static func getUniversalLink(for platforn: Platform) -> URL? {
        let infos = infoDictionary()
        let item = infos.universalLinks.first(where: { $0.platform == platforn.key })
        return (item?.universalLink).flatMap { URL(string: $0) }
    }

    static func getRedirectLink(for platform: Platform) -> URL? {
        let infos = infoDictionary()
        let item = infos.redirectLinks.first(where: { $0.platform == platform.key })
        return (item?.redirectLink).flatMap { URL(string: $0) }
    }
}

extension AppState {

    struct InfoDictionary: Codable {

        let bundleURLSchemes: [BundleURLScheme]
        let miniProgramIDs: [MiniProgramID]
        let redirectLinks: [RedirectLink]
        let universalLinks: [UniversalLink]

        enum CodingKeys: String, CodingKey {
            case bundleURLSchemes = "CFBundleURLTypes"
            case miniProgramIDs = "BMMiniProgramIDTypes"
            case redirectLinks = "BMRedirectLinkTypes"
            case universalLinks = "BMUniversalLinkTypes"
        }
    }
}

extension AppState.InfoDictionary {

    struct BundleURLScheme: Codable {

        let platform: String
        let bundleURLSchemes: [String]

        enum CodingKeys: String, CodingKey {
            case platform = "CFBundleURLName"
            case bundleURLSchemes = "CFBundleURLSchemes"
        }
    }
}

extension AppState.InfoDictionary {

    struct MiniProgramID: Codable {

        let platform: String
        let miniProgramID: String

        enum CodingKeys: String, CodingKey {
            case platform = "BMPlatform"
            case miniProgramID = "BMMiniProgramID"
        }
    }
}

extension AppState.InfoDictionary {

    struct RedirectLink: Codable {

        let platform: String
        let redirectLink: String

        enum CodingKeys: String, CodingKey {
            case platform = "BMPlatform"
            case redirectLink = "BMRedirectLink"
        }
    }
}

extension AppState.InfoDictionary {

    struct UniversalLink: Codable {

        let platform: String
        let universalLink: String

        enum CodingKeys: String, CodingKey {
            case platform = "BMPlatform"
            case universalLink = "BMUniversalLink"
        }
    }
}
