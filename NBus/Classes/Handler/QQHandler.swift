//
//  QQHandler.swift
//  NBus
//
//  Created by nuomi1 on 2021/1/4.
//  Copyright © 2021 nuomi1. All rights reserved.
//

import Foundation
import UIKit

#if canImport(NBusCore)
import NBusCore
#endif

// swiftlint:disable file_length

public class QQHandler {

    public let endpoints: [Endpoint] = [
        Endpoints.QQ.friend,
        Endpoints.QQ.timeline,
    ]

    public let platform: Platform = Platforms.qq

    @BusCheckURLScheme(url: URL(string: "mqq://")!)
    public var isInstalled: Bool

    @BusCheckURLScheme(url: URL(string: "mqqopensdkapiV2://")!)
    public var isSupported: Bool

    @BusCheckURLScheme(url: URL(string: "mqqopensdkminiapp://")!)
    private var isMiniProgramSupported: Bool

    @BusCheckURLScheme(url: URL(string: "mqqopensdknopasteboard://")!)
    private var isNoPasteboardSupported: Bool

    @BusCheckURLScheme(url: URL(string: "mqqopensdklaunchminiapp://")!)
    private var isLaunchMiniProgramSupported: Bool

    private var shareCompletionHandler: Bus.ShareCompletionHandler?
    private var oauthCompletionHandler: Bus.OauthCompletionHandler?
    private var launchCompletionHandler: Bus.LaunchCompletionHandler?

    public let appID: String
    public let universalLink: URL

    @BusUserDefaults(key: ShareOptionKeys.signToken)
    private var signToken: String?

    private var lastSignTokenData: LastSignTokenData?

    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .base64
        return decoder
    }()

    private lazy var iso8601DateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter
    }()

    public init(appID: String, universalLink: URL) {
        self.appID = appID
        self.universalLink = universalLink
    }
}

extension QQHandler: ShareHandlerType {

    // swiftlint:disable cyclomatic_complexity function_body_length

    public func share(
        message: MessageType,
        to endpoint: Endpoint,
        options: [Bus.ShareOptionKey: Any],
        completionHandler: @escaping Bus.ShareCompletionHandler
    ) {
        let checkResult = checkShareSupported(message: message, to: endpoint)

        guard case .success = checkResult else {
            completionHandler(checkResult)
            return
        }

        shareCompletionHandler = completionHandler

        var urlItems: [String: String?] = [:]
        var pasteBoardItems: [String: Any] = [:]

        urlItems["cflag"] = cflag(endpoint, message.identifier)!
        urlItems["shareType"] = shareType(endpoint, message.identifier)!

        if let message = message as? MediaMessageType {
            urlItems["title"] = message.title?.bus.base64EncodedString
            urlItems["description"] = message.description?.bus.base64EncodedString

            pasteBoardItems["previewimagedata"] = message.thumbnail
        }

        switch message {
        case let message as TextMessage:
            urlItems["file_type"] = "text"

            urlItems["file_data"] = message.text.bus.base64EncodedString

        case let message as ImageMessage:
            urlItems["file_type"] = "img"

            pasteBoardItems["file_data"] = message.data

        case let message as AudioMessage:
            urlItems["file_type"] = "audio"

            urlItems["url"] = message.link.absoluteString.bus.base64EncodedString

            urlItems["flashurl"] = message.dataLink?.absoluteString.bus.base64EncodedString

        case let message as VideoMessage:
            urlItems["file_type"] = "video"

            urlItems["url"] = message.link.absoluteString.bus.base64EncodedString

        case let message as WebPageMessage:
            urlItems["file_type"] = "news"

            urlItems["url"] = message.link.absoluteString.bus.base64EncodedString

        case let message as FileMessage:
            urlItems["file_type"] = "localFile"

            urlItems["fileName"] = message.fullName

            pasteBoardItems["file_data"] = message.data

        case let message as MiniProgramMessage:
            guard isMiniProgramSupported else {
                completionHandler(.failure(.unsupportedApplication))
                return
            }

            urlItems["file_type"] = "news"

            urlItems["url"] = message.link.absoluteString.bus.base64EncodedString

            urlItems["mini_appid"] = message.miniProgramID
            urlItems["mini_path"] = message.path.bus.base64EncodedString
            urlItems["mini_weburl"] = message.link.absoluteString.bus.base64EncodedString
            urlItems["mini_type"] = miniProgramType(message.miniProgramType)
            urlItems["mini_code64"] = "1"

        default:
            busAssertionFailure()
            completionHandler(.failure(.unsupportedMessage))
            return
        }

        if message is WebPageMessage || message is MiniProgramMessage {
            setPasteboardIfNeeded(with: &pasteBoardItems, into: &urlItems)
        }

        setPasteboardIfNeeded(with: &pasteBoardItems, in: .general)

        if !pasteBoardItems.isEmpty {
            urlItems["generalpastboard"] = "1"
            urlItems["objectlocation"] = "pasteboard"
        }

        if signToken == nil {
            lastSignTokenData = .share(pasteBoardItems: pasteBoardItems, urlItems: urlItems)
        }

        open(generateShareUniversalLink(with: urlItems), completionHandler: shareCompletionHandler)
    }

    // swiftlint:enable cyclomatic_complexity function_body_length

    private func cflag(_ endpoint: Endpoint, _ message: Message) -> String? {
        var flags: [Int] = []

        switch endpoint {
        case Endpoints.QQ.friend:
            flags.append(2) // kQQAPICtrlFlagQZoneShareForbid

            if message == Messages.file {
                flags.append(16) // kQQAPICtrlFlagQQShareDataline
            }

            if message == Messages.miniProgram {
                flags.append(64) // kQQAPICtrlFlagQQShareEnableMiniProgram
            }
        case Endpoints.QQ.timeline:
            break
        default:
            return nil
        }

        let result = flags.reduce(0) { result, flag in result | flag }
        return "\(result)"
    }

    private func shareType(_ endpoint: Endpoint, _ message: Message) -> String? {
        let result: Int

        switch endpoint {
        case Endpoints.QQ.friend:
            switch message {
            case Messages.text,
                 Messages.image,
                 Messages.audio,
                 Messages.video,
                 Messages.webPage,
                 Messages.file,
                 Messages.miniProgram:
                result = 0
            default:
                return nil
            }
        case Endpoints.QQ.timeline:
            switch message {
            case Messages.text,
                 Messages.image:
                result = 0
            case Messages.audio,
                 Messages.video,
                 Messages.webPage:
                result = 1
            default:
                return nil
            }
        default:
            return nil
        }

        return "\(result)"
    }

    private func miniProgramType(_ miniProgramType: MiniProgramMessage.MiniProgramType) -> String {
        let result: Int

        switch miniProgramType {
        case .release:
            result = 3 // MiniProgramType_Online
        case .test:
            result = 1 // MiniProgramType_Test
        case .preview:
            result = 4 // MiniProgramType_Preview
        }

        return "\(result)"
    }
}

extension QQHandler: OauthHandlerType {

    public func oauth(
        options: [Bus.OauthOptionKey: Any],
        completionHandler: @escaping Bus.OauthCompletionHandler
    ) {
        let checkResult = checkOauthSupported()

        guard case .success = checkResult else {
            completionHandler(checkResult.flatMap { _ in .failure(.unknown) })
            return
        }

        oauthCompletionHandler = completionHandler

        var urlItems: [String: String?] = [:]
        var pasteBoardItems: [String: Any] = [:]

        pasteBoardItems["app_id"] = appNumber
        pasteBoardItems["app_name"] = displayName
        pasteBoardItems["bundleid"] = bundleID
        pasteBoardItems["client_id"] = appNumber
        pasteBoardItems["refUniversallink"] = universalLink.absoluteString
        pasteBoardItems["response_type"] = "token"
        pasteBoardItems["scope"] = "get_user_info"
        pasteBoardItems["sdkp"] = "i"
        pasteBoardItems["sdkv"] = sdkVersion
        pasteBoardItems["status_machine"] = statusMachine
        pasteBoardItems["status_os"] = statusOS
        pasteBoardItems["status_version"] = statusVersion

        setPasteboardIfNeeded(with: &pasteBoardItems, into: &urlItems)

        setPasteboardIfNeeded(with: &pasteBoardItems, in: .general)

        if !pasteBoardItems.isEmpty {
            urlItems["generalpastboard"] = "1"
        }

        open(generateOauthUniversalLink(with: urlItems), completionHandler: oauthCompletionHandler)
    }
}

extension QQHandler: LaunchHandlerType {

    public func launch(
        program: MiniProgramMessage,
        options: [Bus.LaunchOptionKey: Any],
        completionHandler: @escaping Bus.LaunchCompletionHandler
    ) {
        let checkResult = checkOauthSupported()

        guard case .success = checkResult, isLaunchMiniProgramSupported else {
            completionHandler(checkResult.flatMap { _ in .failure(.unsupportedApplication) })
            return
        }

        launchCompletionHandler = completionHandler

        var urlItems: [String: String?] = [:]

        urlItems["mini_appid"] = program.miniProgramID
        urlItems["mini_path"] = program.path.bus.base64EncodedString
        urlItems["mini_type"] = miniProgramType(program.miniProgramType)

        if signToken == nil {
            lastSignTokenData = .launch(urlItems: urlItems)
        }

        open(generateLaunchUniversalLink(with: urlItems), completionHandler: launchCompletionHandler)
    }
}

extension QQHandler {

    private var appNumber: String {
        appID.trimmingCharacters(in: .letters)
    }

    private var sdkShortVersion: String {
        "3.5.1"
    }

    private var sdkVersion: String {
        "3.5.1_lite"
    }

    private var statusMachine: String {
        UIDevice.current.bus.machine
    }

    private var statusOS: String {
        UIDevice.current.systemVersion
    }

    private var statusVersion: String {
        "\(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)"
    }

    private var txID: String {
        "QQ\(String(format: "%08llX", (appNumber as NSString).longLongValue))"
    }
}

extension QQHandler {

    private func setPasteboardIfNeeded(
        with pasteBoardItems: inout [String: Any],
        in pasteboard: UIPasteboard
    ) {
        guard !pasteBoardItems.isEmpty else {
            return
        }

        pasteBoardItems["pasted_string"] = oldText

        let pbData = generatePasteboardData(with: pasteBoardItems)

        pasteboard.setData(pbData, forPasteboardType: "com.tencent.mqq.api.apiLargeData")
    }

    private func setPasteboardIfNeeded(
        with pasteBoardItems: inout [String: Any],
        into urlItems: inout [String: String?]
    ) {
        guard isNoPasteboardSupported else {
            return
        }

        let pbData = generatePasteboardData(with: pasteBoardItems)

        urlItems["objectlocation"] = "url"
        urlItems["pasteboard"] = pbData.base64EncodedString()

        pasteBoardItems = [:]
    }

    private func generatePasteboardData(with pasteBoardItems: [String: Any]) -> Data {
        NSKeyedArchiver.archivedData(withRootObject: pasteBoardItems)
    }
}

extension QQHandler {

    private func generateShareUniversalLink(with urlItems: [String: String?]) -> URL? {
        var components = generateGeneralUniversalLink()

        components.path = "/opensdkul/mqqapi/share/to_fri"

        var urlItems = urlItems

        urlItems["appsign_token"] = signToken

        urlItems["callback_name"] = txID
        urlItems["callback_type"] = "scheme"
        urlItems["src_type"] = "app"
        urlItems["thirdAppDisplayName"] = displayName.bus.base64EncodedString
        urlItems["version"] = "1"

        components.queryItems = components.bus.mergingQueryItems(urlItems)

        return components.url
    }

    private func generateOauthUniversalLink(with urlItems: [String: String?]) -> URL? {
        var components = generateGeneralUniversalLink()

        components.path = "/opensdkul/mqqOpensdkSSoLogin/SSoLogin/\(appID)"

        components.queryItems = components.bus.mergingQueryItems(urlItems)

        return components.url
    }

    private func generateLaunchUniversalLink(with urlItems: [String: String?]) -> URL? {
        var components = generateGeneralUniversalLink()

        components.path = "/opensdkul/mqqapi/profile/sdk_launch_mini_app"

        var urlItems = urlItems

        urlItems["appsign_token"] = signToken

        urlItems["appid"] = appNumber
        urlItems["callback_name"] = txID
        urlItems["callback_type"] = "scheme"
        urlItems["src_type"] = "app"
        urlItems["thirdAppDisplayName"] = displayName.bus.base64EncodedString
        urlItems["version"] = "1"

        components.queryItems = components.bus.mergingQueryItems(urlItems)

        return components.url
    }

    private func generateGeneralUniversalLink() -> URLComponents {
        var components = URLComponents()

        components.scheme = "https"
        components.host = "qm.qq.com"

        var urlItems: [String: String?] = [:]

        urlItems["appsign_txid"] = txID
        urlItems["bundleid"] = bundleID.bus.base64EncodedString
        urlItems["sdkv"] = sdkShortVersion

        components.queryItems = components.bus.mergingQueryItems(urlItems)

        return components
    }
}

extension QQHandler: BusQQHandlerHelper {}

extension QQHandler: BusOpenExternalURLHelper {}

extension QQHandler: BusGetCommonInfoHelper {}

extension QQHandler: OpenURLHandlerType {

    public func openURL(_ url: URL) {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            busAssertionFailure()
            return
        }

        handleGeneral(with: components)
    }
}

extension QQHandler: OpenUserActivityHandlerType {

    public func openUserActivity(_ userActivity: NSUserActivity) {
        guard
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            busAssertionFailure()
            return
        }

        switch components.path {
        case universalLink.appendingPathComponent("\(bundleID)/mqqsignapp").path:
            handleSignToken(with: components)
        case universalLink.appendingPathComponent("\(bundleID)").path:
            handleActionInfo(with: components)
        default:
            busAssertionFailure()
        }
    }
}

extension QQHandler {

    private func handleSignToken(with components: URLComponents) {
        guard
            let infos = getJSON(from: components, with: "appsign_extrainfo") ?? getPlist(from: .general),
            let signToken = infos["appsign_token"] as? String,
            let lastSignTokenData = lastSignTokenData
        else {
            busAssertionFailure()
            return
        }

        self.signToken = signToken

        switch lastSignTokenData {
        case .share(var pasteBoardItems, let urlItems):
            setPasteboardIfNeeded(with: &pasteBoardItems, in: .general)
            open(generateShareUniversalLink(with: urlItems), completionHandler: shareCompletionHandler)
        case let .launch(urlItems):
            open(generateLaunchUniversalLink(with: urlItems), completionHandler: launchCompletionHandler)
        }

        self.lastSignTokenData = nil
    }

    private func handleActionInfo(with components: URLComponents) {
        guard
            let infos = getJSON(from: components, with: "sdkactioninfo")
        else {
            busAssertionFailure()
            return
        }

        var components = URLComponents()

        components.scheme = infos["sdk_action_sheme"]
        components.host = infos["sdk_action_host"]
        components.path = infos["sdk_action_path"] ?? ""
        components.query = infos["sdk_action_query"]

        handleGeneral(with: components)
    }

    private func handleGeneral(with components: URLComponents) {
        switch components.host {
        case "response_from_qq" where components.path == "":
            handleShare(with: components)
        case "qzapp" where components.path == "/mqzone/0":
            handleOauth(with: components)
        default:
            busAssertionFailure()
        }
    }
}

extension QQHandler {

    private func handleShare(with components: URLComponents) {
        guard
            let item = components.queryItems?.first(where: { $0.name == "error" })
        else {
            busAssertionFailure()
            shareCompletionHandler?(.failure(.invalidParameter))
            return
        }

        switch item.value {
        case "0":
            shareCompletionHandler?(.success(()))
        case "900101":
            // msg_body error: url empty or contain illegal char
            shareCompletionHandler?(.failure(.invalidParameter))
        case "-4":
            // the user give up the current operation
            shareCompletionHandler?(.failure(.userCancelled))
        case "--100070005":
            shareCompletionHandler?(.failure(.invalidParameter))
        case "--1000710008":
            // 主体信息不一致，无法打开
            shareCompletionHandler?(.failure(.invalidParameter))
        default:
            busAssertionFailure()
            shareCompletionHandler?(.failure(.unknown))
        }
    }

    private func handleOauth(with components: URLComponents) {
        guard
            let infos = getPlist(from: components, with: "pasteboard") ?? getPlist(from: .general)
        else {
            busAssertionFailure()
            oauthCompletionHandler?(.failure(.invalidParameter))
            return
        }

        let isUserCancelled = infos["user_cancelled"] as? String

        switch isUserCancelled {
        case "YES":
            oauthCompletionHandler?(.failure(.userCancelled))
        case "NO":
            let accessToken = infos["access_token"] as? String
            let expirationDate: String? = (infos["expires_in"] as? Int).map {
                let timeInterval = TimeInterval($0)
                let date = Date().addingTimeInterval(timeInterval)
                return iso8601DateFormatter.string(from: date)
            }
            let openID = infos["openid"] as? String

            let parameters = [
                OauthInfoKeys.accessToken: accessToken,
                OauthInfoKeys.expirationDate: expirationDate,
                OauthInfoKeys.openID: openID,
            ]
            .bus
            .compactMapContent()

            if !parameters.isEmpty {
                oauthCompletionHandler?(.success(parameters))
            } else {
                busAssertionFailure()
                oauthCompletionHandler?(.failure(.unknown))
            }
        default:
            busAssertionFailure()
        }
    }
}

extension QQHandler {

    private func getJSON(from components: URLComponents, with name: String) -> [String: String]? {
        guard
            let item = components.queryItems?.first(where: { $0.name == name }),
            let itemData = item.value.flatMap({ Data(base64Encoded: $0) }),
            let infos = try? jsonDecoder.decode([String: String].self, from: itemData)
        else {
            return nil
        }

        return infos
    }

    private func getPlist(from components: URLComponents, with name: String) -> [String: Any]? {
        guard
            let item = components.queryItems?.first(where: { $0.name == name }),
            let itemData = item.value.flatMap({ Data(base64Encoded: $0) }),
            let infos = NSKeyedUnarchiver.unarchiveObject(with: itemData) as? [String: Any]
        else {
            return nil
        }

        return infos
    }

    private func getPlist(from pasteboard: UIPasteboard) -> [String: Any]? {
        guard
            let itemData = pasteboard.data(forPasteboardType: "com.tencent.\(appID)"),
            let infos = NSKeyedUnarchiver.unarchiveObject(with: itemData) as? [String: Any]
        else {
            return nil
        }

        return infos
    }
}

extension QQHandler {

    public enum ShareOptionKeys {

        public static let signToken = Bus.ShareOptionKey(rawValue: "com.nuomi1.bus.qqHandler.signToken")
    }
}

extension QQHandler {

    public enum OauthInfoKeys {

        public static let accessToken = Bus.OauthInfoKeys.QQ.accessToken

        public static let expirationDate = Bus.OauthInfoKeys.QQ.expirationDate

        public static let openID = Bus.OauthInfoKeys.QQ.openID
    }
}

extension QQHandler {

    private enum LastSignTokenData {

        case share(pasteBoardItems: [String: Any], urlItems: [String: String?])

        case launch(urlItems: [String: String?])
    }
}
