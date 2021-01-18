//
//  QQHandler.swift
//  NBus
//
//  Created by nuomi1 on 2021/1/4.
//  Copyright © 2021 nuomi1. All rights reserved.
//

import Foundation

// swiftlint:disable file_length

public class QQHandler {

    public let endpoints: [Endpoint] = [
        Endpoints.QQ.friend,
        Endpoints.QQ.timeline,
    ]

    public let platform: Platform = Platforms.qq

    public var isInstalled: Bool {
        guard let url = URL(string: "mqq://") else {
            assertionFailure()
            return false
        }

        return UIApplication.shared.canOpenURL(url)
    }

    private var shareCompletionHandler: Bus.ShareCompletionHandler?
    private var oauthCompletionHandler: Bus.OauthCompletionHandler?

    public let appID: String
    public let universalLink: URL

    @BusUserDefaults(key: ShareOptionKeys.signToken)
    private var signToken: String?

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
        guard isInstalled else {
            completionHandler(.failure(.missingApplication))
            return
        }

        guard canShare(message: message.identifier, to: endpoint) else {
            completionHandler(.failure(.unsupportedMessage))
            return
        }

        guard
            let identifierEncoded = identifier?.bus.base64EncodedString,
            let cflag = cflag(endpoint, message.identifier),
            let shareType = shareType(endpoint, message.identifier),
            let displayNameEncoded = displayName?.bus.base64EncodedString
        else {
            assertionFailure()
            completionHandler(.failure(.invalidParameter))
            return
        }

        shareCompletionHandler = completionHandler

        var urlItems: [String: String] = [:]
        var pasteBoardItems: [String: Any?] = [:]

        urlItems["appsign_txid"] = txID
        urlItems["bundleid"] = identifierEncoded
        urlItems["callback_name"] = txID
        urlItems["callback_type"] = "scheme"
        urlItems["cflag"] = cflag
        urlItems["generalpastboard"] = "1"
        urlItems["sdkv"] = sdkShortVersion
        urlItems["shareType"] = shareType
        urlItems["src_type"] = "app"
        urlItems["thirdAppDisplayName"] = displayNameEncoded
        urlItems["version"] = "1"

        if let signToken = signToken {
            urlItems["appsign_token"] = signToken
        }

        if let oldText = oldText {
            pasteBoardItems["pasted_string"] = oldText
        }

        if let message = message as? MediaMessageType {
            if let title = message.title?.bus.base64EncodedString {
                urlItems["title"] = title
            }

            if let description = message.description?.bus.base64EncodedString {
                urlItems["description"] = description
            }

            if let thumbnail = message.thumbnail {
                pasteBoardItems["previewimagedata"] = thumbnail
            }
        }

        switch message {
        case let message as TextMessage:
            guard
                let text = message.text.bus.base64EncodedString
            else {
                completionHandler(.failure(.invalidParameter))
                return
            }

            urlItems["file_type"] = "text"

            urlItems["file_data"] = text

        case let message as ImageMessage:
            urlItems["file_type"] = "img"

            pasteBoardItems["file_data"] = message.data

        case let message as AudioMessage:
            guard
                let url = message.link.absoluteString.bus.base64EncodedString
            else {
                completionHandler(.failure(.invalidParameter))
                return
            }

            urlItems["file_type"] = "audio"

            urlItems["url"] = url

            if let flashURL = message.dataLink?.absoluteString.bus.base64EncodedString {
                urlItems["flashurl"] = flashURL
            }

        case let message as VideoMessage:
            guard
                let url = message.link.absoluteString.bus.base64EncodedString
            else {
                completionHandler(.failure(.invalidParameter))
                return
            }

            urlItems["file_type"] = "video"

            urlItems["url"] = url

        case let message as WebPageMessage:
            guard
                let url = message.link.absoluteString.bus.base64EncodedString
            else {
                completionHandler(.failure(.invalidParameter))
                return
            }

            urlItems["file_type"] = "news"

            urlItems["url"] = url

        case let message as FileMessage:
            urlItems["file_type"] = "localFile"

            if let fileName = message.fullName {
                urlItems["fileName"] = fileName
            }

            pasteBoardItems["file_data"] = message.data

        case let message as MiniProgramMessage:
            guard
                let path = message.path.bus.base64EncodedString,
                let url = message.link.absoluteString.bus.base64EncodedString
            else {
                completionHandler(.failure(.invalidParameter))
                return
            }

            urlItems["file_type"] = "news"

            urlItems["url"] = url

            if let thumbnail = message.thumbnail {
                pasteBoardItems["previewimagedata"] = thumbnail
            }

            urlItems["mini_appid"] = message.miniProgramID
            urlItems["mini_path"] = path
            urlItems["mini_weburl"] = url
            urlItems["mini_type"] = miniProgramType(message.miniProgramType)
            urlItems["mini_code64"] = "1"

        default:
            assertionFailure()
            completionHandler(.failure(.unsupportedMessage))
            return
        }

        let pbItems = pasteBoardItems.compactMapValues { $0 }

        if !pbItems.isEmpty {
            let pbData = NSKeyedArchiver.archivedData(withRootObject: pbItems)

            UIPasteboard.general.setData(
                pbData,
                forPasteboardType: "com.tencent.mqq.api.apiLargeData"
            )
        }

        if pbItems.contains(where: { $0.key == "file_data" }) {
            urlItems["objectlocation"] = "pasteboard"
        }

        var components = URLComponents()

        components.scheme = "https"
        components.host = "qm.qq.com"
        components.path = "/opensdkul/mqqapi/share/to_fri"

        components.queryItems = urlItems.map { key, value in
            URLQueryItem(name: key, value: value)
        }

        guard let url = components.url else {
            completionHandler(.failure(.invalidParameter))
            return
        }

        UIApplication.shared.open(url, options: [.universalLinksOnly: true]) { result in
            if !result {
                completionHandler(.failure(.unknown))
            }
        }
    }

    // swiftlint:enable cyclomatic_complexity function_body_length

    private func canShare(message: Message, to endpoint: Endpoint) -> Bool {
        switch endpoint {
        case Endpoints.QQ.friend:
            return true
        case Endpoints.QQ.timeline:
            return ![
                Messages.file,
                Messages.miniProgram,
            ].contains(message)
        default:
            assertionFailure()
            return false
        }
    }

    private var appNumber: String {
        appID.trimmingCharacters(in: .letters)
    }

    private var txID: String {
        "QQ\(String(format: "%08llX", (appNumber as NSString).longLongValue))"
    }

    private var identifier: String? {
        Bundle.main.bus.identifier
    }

    private var displayName: String? {
        Bundle.main.bus.displayName
    }

    private var sdkShortVersion: String {
        "3.5.1"
    }

    private var sdkVersion: String {
        "3.5.1_lite"
    }

    private var oldText: String? {
        UIPasteboard.general.bus.oldText
    }

    private func cflag(_ endpoint: Endpoint, _ message: Message) -> String? {
        var flags: [Int] = []

        switch endpoint {
        case Endpoints.QQ.friend:
            flags.append(2) // qqapiCtrlFlagQZoneShareForbid

            if message == Messages.file {
                flags.append(16) // qqapiCtrlFlagQQShareDataline
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

    private func miniProgramType(_ miniProgramType: MiniProgramMessage.MiniProgramType) -> String {
        let result: Int

        switch miniProgramType {
        case .release:
            result = 3 // online
        case .test:
            result = 1 // test
        case .preview:
            result = 4 // preview
        }

        return "\(result)"
    }

    private func shareType(_ endpoint: Endpoint, _ message: Message) -> String? {
        switch endpoint {
        case Endpoints.QQ.friend:
            return "0"
        case Endpoints.QQ.timeline:
            return ![
                Messages.text,
                Messages.image,
            ].contains(message)
                ? "1" : "0"
        default:
            return nil
        }
    }
}

extension QQHandler: OauthHandlerType {

    // swiftlint:disable function_body_length

    public func oauth(
        options: [Bus.OauthOptionKey: Any],
        completionHandler: @escaping Bus.OauthCompletionHandler
    ) {
        guard isInstalled else {
            completionHandler(.failure(.missingApplication))
            return
        }

        guard
            let displayName = displayName,
            let identifier = identifier,
            let identifierEncoded = identifier.bus.base64EncodedString
        else {
            assertionFailure()
            completionHandler(.failure(.invalidParameter))
            return
        }

        oauthCompletionHandler = completionHandler

        var urlItems: [String: String] = [:]
        var pasteBoardItems: [String: Any?] = [:]

        pasteBoardItems["app_id"] = appNumber
        pasteBoardItems["app_name"] = displayName
        pasteBoardItems["bundleid"] = identifier
        pasteBoardItems["client_id"] = appNumber
        pasteBoardItems["refUniversallink"] = universalLink.absoluteString
        pasteBoardItems["response_type"] = "token"
        pasteBoardItems["scope"] = "get_user_info"
        pasteBoardItems["sdkp"] = "i"
        pasteBoardItems["sdkv"] = sdkVersion
        pasteBoardItems["status_machine"] = statusMachine
        pasteBoardItems["status_os"] = statusOS
        pasteBoardItems["status_version"] = statusVersion

        let pbItems = pasteBoardItems.compactMapValues { $0 }
        let pbData = NSKeyedArchiver.archivedData(withRootObject: pbItems)

        urlItems["appsign_txid"] = txID
        urlItems["bundleid"] = identifierEncoded
        urlItems["objectlocation"] = "url"
        urlItems["pasteboard"] = pbData.base64EncodedString()
        urlItems["sdkv"] = sdkShortVersion

        var components = URLComponents()

        components.scheme = "https"
        components.host = "qm.qq.com"
        components.path = "/opensdkul/mqqOpensdkSSoLogin/SSoLogin/\(appID)"

        components.queryItems = urlItems.map { key, value in
            URLQueryItem(name: key, value: value)
        }

        guard let url = components.url else {
            completionHandler(.failure(.invalidParameter))
            return
        }

        UIApplication.shared.open(url, options: [.universalLinksOnly: true]) { result in
            if !result {
                completionHandler(.failure(.unknown))
            }
        }
    }

    // swiftlint:enable function_body_length

    private var statusMachine: String {
        UIDevice.current.bus.machine
    }

    private var statusOS: String {
        UIDevice.current.systemVersion
    }

    private var statusVersion: String {
        "\(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)"
    }
}

extension QQHandler: OpenURLHandlerType {

    public func openURL(_ url: URL) {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            assertionFailure()
            return
        }

        handleGeneral(with: components)
    }
}

extension QQHandler: OpenUserActivityHandlerType {

    public func openUserActivity(_ userActivity: NSUserActivity) {
        guard
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let identifier = Bundle.main.bus.identifier
        else {
            assertionFailure()
            return
        }

        switch components.path {
        case universalLink.appendingPathComponent("\(identifier)/mqqsignapp").path:
            handleSignToken(with: components)
        case universalLink.appendingPathComponent("\(identifier)").path:
            handleActionInfo(with: components)
        default:
            assertionFailure()
        }
    }
}

extension QQHandler {

    private func handleSignToken(with components: URLComponents) {
        guard
            let infos = getSignTokenInfos(from: components) ?? getSignTokenInfos(from: .general),
            let appSignRedirect = infos["appsign_redirect"],
            let appSignToken = infos["appsign_token"],
            var components = URLComponents(string: appSignRedirect)
        else {
            assertionFailure()
            return
        }

        signToken = appSignToken

        var items: [String: String] = [:]

        items["openredirect"] = "1"
        items["appsign_token"] = appSignToken

        components.scheme = "https"
        components.host = "qm.qq.com"
        components.path = "/opensdkul/mqqapi/share/to_fri"

        components.queryItems?.append(contentsOf: items.map { key, value in
            URLQueryItem(name: key, value: value)
        })

        guard let url = components.url else {
            shareCompletionHandler?(.failure(.invalidParameter))
            return
        }

        UIApplication.shared.open(url, options: [.universalLinksOnly: true]) { [weak self] result in
            if !result {
                self?.shareCompletionHandler?(.failure(.unknown))
            }
        }
    }

    private func getSignTokenInfos(from components: URLComponents) -> [String: String]? {
        getJSON(from: components, with: "appsign_extrainfo")
    }

    private func getSignTokenInfos(from pasteboard: UIPasteboard) -> [String: String]? {
        guard
            let itemData = pasteboard.data(forPasteboardType: "com.tencent.\(appID)"),
            let infos = NSKeyedUnarchiver.unarchiveObject(with: itemData) as? [String: Any]
        else {
            return nil
        }

        if let pbItems = infos["appsign_redirect_pasteboard"] {
            let pbData = NSKeyedArchiver.archivedData(withRootObject: pbItems)

            UIPasteboard.general.setData(
                pbData,
                forPasteboardType: "com.tencent.mqq.api.apiLargeData"
            )
        }

        return infos.compactMapValues { $0 as? String }
    }

    private func getJSON(from components: URLComponents, with name: String) -> [String: String]? {
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .base64

        guard
            let item = components.queryItems?.first(where: { $0.name == name }),
            let itemData = item.value.flatMap({ Data(base64Encoded: $0) }),
            let infos = try? decoder.decode([String: String].self, from: itemData)
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

    private func handleActionInfo(with components: URLComponents) {
        guard
            let infos = getJSON(from: components, with: "sdkactioninfo")
        else {
            assertionFailure()
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
            assertionFailure()
        }
    }
}

extension QQHandler {

    private func handleShare(with components: URLComponents) {
        guard
            let item = components.queryItems?.first(where: { $0.name == "error" })
        else {
            assertionFailure()
            return
        }

        switch item.value {
        case "0":
            shareCompletionHandler?(.success(()))
        case "-4":
            shareCompletionHandler?(.failure(.userCancelled))
        default:
            shareCompletionHandler?(.failure(.unknown))
        }
    }

    private func handleOauth(with components: URLComponents) {
        guard
            let infos = getPlist(from: components, with: "pasteboard")
        else {
            assertionFailure()
            return
        }

        let isUserCancelled = infos["user_cancelled"] as? String

        switch isUserCancelled {
        case "YES":
            oauthCompletionHandler?(.failure(.userCancelled))
        case "NO":
            let accessToken = infos["access_token"] as? String
            let openID = infos["openid"] as? String

            let parameters = [
                OauthInfoKeys.accessToken: accessToken,
                OauthInfoKeys.openID: openID,
            ]
            .bus
            .compactMapContent()

            if !parameters.isEmpty {
                oauthCompletionHandler?(.success(parameters))
            } else {
                oauthCompletionHandler?(.failure(.unknown))
            }
        default:
            assertionFailure()
        }
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

        public static let openID = Bus.OauthInfoKeys.QQ.openID
    }
}
