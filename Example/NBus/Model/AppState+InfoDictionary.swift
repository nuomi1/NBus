//
//  AppState+InfoDictionary.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation

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
