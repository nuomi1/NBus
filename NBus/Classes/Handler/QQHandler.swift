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

    private var isSupported: Bool {
        guard let url = URL(string: "mqqopensdkapiV2://") else {
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
        guard isInstalled else {
            completionHandler(.failure(.missingApplication))
            return
        }

        guard isSupported else {
            completionHandler(.failure(.unsupportedApplication))
            return
        }

        guard canShare(message: message.identifier, to: endpoint) else {
            completionHandler(.failure(.unsupportedMessage))
            return
        }

        guard
            let cflag = cflag(endpoint, message.identifier),
            let shareType = shareType(endpoint, message.identifier)
        else {
            assertionFailure()
            completionHandler(.failure(.invalidParameter))
            return
        }

        shareCompletionHandler = completionHandler

        var urlItems: [String: String] = [:]
        var pasteBoardItems: [String: Any] = [:]

        urlItems["cflag"] = cflag
        urlItems["shareType"] = shareType

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
                assertionFailure()
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
                assertionFailure()
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
                assertionFailure()
                completionHandler(.failure(.invalidParameter))
                return
            }

            urlItems["file_type"] = "video"

            urlItems["url"] = url

        case let message as WebPageMessage:
            guard
                let url = message.link.absoluteString.bus.base64EncodedString
            else {
                assertionFailure()
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
                assertionFailure()
                completionHandler(.failure(.invalidParameter))
                return
            }

            urlItems["file_type"] = "news"

            urlItems["title"] = url
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

        setPasteboard(with: pasteBoardItems, in: .general)

        if pasteBoardItems.contains(where: { $0.key == "file_data" }) {
            urlItems["objectlocation"] = "pasteboard"
        } else if message is MiniProgramMessage {
            urlItems["objectlocation"] = "url"
        }

        guard let url = generateShareUniversalLink(with: urlItems) else {
            assertionFailure()
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
            return [
                Messages.text,
                Messages.image,
                Messages.audio,
                Messages.video,
                Messages.webPage,
                Messages.file,
                Messages.miniProgram,
            ].contains(message)
        case Endpoints.QQ.timeline:
            return [
                Messages.text,
                Messages.image,
                Messages.audio,
                Messages.video,
                Messages.webPage,
            ].contains(message)
        default:
            assertionFailure()
            return false
        }
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
            result = 3 // online
        case .test:
            result = 1 // test
        case .preview:
            result = 4 // preview
        }

        return "\(result)"
    }
}

extension QQHandler: OauthHandlerType {

    public func oauth(
        options: [Bus.OauthOptionKey: Any],
        completionHandler: @escaping Bus.OauthCompletionHandler
    ) {
        guard isInstalled else {
            completionHandler(.failure(.missingApplication))
            return
        }

        guard isSupported else {
            completionHandler(.failure(.unsupportedApplication))
            return
        }

        guard
            let displayName = displayName,
            let bundleID = bundleID
        else {
            assertionFailure()
            completionHandler(.failure(.invalidParameter))
            return
        }

        oauthCompletionHandler = completionHandler

        var urlItems: [String: String] = [:]
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

        let pbData = generatePasteboardData(with: pasteBoardItems)

        urlItems["objectlocation"] = "url"
        urlItems["pasteboard"] = pbData.base64EncodedString()

        guard let url = generateOauthUniversalLink(with: urlItems) else {
            assertionFailure()
            completionHandler(.failure(.invalidParameter))
            return
        }

        UIApplication.shared.open(url, options: [.universalLinksOnly: true]) { result in
            if !result {
                completionHandler(.failure(.unknown))
            }
        }
    }
}

extension QQHandler {

    private var appNumber: String {
        appID.trimmingCharacters(in: .letters)
    }

    private var bundleID: String? {
        Bundle.main.bus.identifier
    }

    private var displayName: String? {
        Bundle.main.bus.displayName
    }

    private var oldText: String? {
        UIPasteboard.general.bus.oldText
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

    private func setPasteboard(
        with pasteBoardItems: [String: Any],
        in pasteboard: UIPasteboard
    ) {
        let pbData = generatePasteboardData(with: pasteBoardItems)

        pasteboard.setData(pbData, forPasteboardType: "com.tencent.mqq.api.apiLargeData")
    }

    private func generatePasteboardData(with pasteBoardItems: [String: Any]) -> Data {
        NSKeyedArchiver.archivedData(withRootObject: pasteBoardItems)
    }
}

extension QQHandler {

    private func generateShareUniversalLink(with urlItems: [String: String]) -> URL? {
        guard
            var components = generateGeneralUniversalLink(),
            let displayNameEncoded = displayName?.bus.base64EncodedString
        else {
            return nil
        }

        components.path = "/opensdkul/mqqapi/share/to_fri"

        var urlItems = urlItems

        if let signToken = signToken {
            urlItems["appsign_token"] = signToken
        }

        urlItems["callback_name"] = txID
        urlItems["callback_type"] = "scheme"
        urlItems["generalpastboard"] = "1"
        urlItems["src_type"] = "app"
        urlItems["thirdAppDisplayName"] = displayNameEncoded
        urlItems["version"] = "1"

        components.queryItems?.append(contentsOf: urlItems.map { key, value in
            URLQueryItem(name: key, value: value)
        })

        return components.url
    }

    private func generateOauthUniversalLink(with urlItems: [String: String]) -> URL? {
        guard
            var components = generateGeneralUniversalLink()
        else {
            return nil
        }

        components.path = "/opensdkul/mqqOpensdkSSoLogin/SSoLogin/\(appID)"

        components.queryItems?.append(contentsOf: urlItems.map { key, value in
            URLQueryItem(name: key, value: value)
        })

        return components.url
    }

    private func generateGeneralUniversalLink() -> URLComponents? {
        guard
            let bundleIDEncoded = bundleID?.bus.base64EncodedString
        else {
            return nil
        }

        var components = URLComponents()

        components.scheme = "https"
        components.host = "qm.qq.com"

        var urlItems: [String: String] = [:]

        urlItems["appsign_txid"] = txID
        urlItems["bundleid"] = bundleIDEncoded
        urlItems["sdkv"] = sdkShortVersion

        components.queryItems = urlItems.map { key, value in
            URLQueryItem(name: key, value: value)
        }

        return components
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
            let components = URLComponents(string: appSignRedirect)
        else {
            assertionFailure()
            shareCompletionHandler?(.failure(.invalidParameter))
            return
        }

        signToken = appSignToken

        let items = components.queryItems?.reduce(into: [String: String]()) { result, item in
            if let value = item.value {
                result[item.name] = value
            }
        } ?? [:]

        guard let url = generateShareUniversalLink(with: items) else {
            assertionFailure()
            shareCompletionHandler?(.failure(.invalidParameter))
            return
        }

        UIApplication.shared.open(url, options: [.universalLinksOnly: true]) { [weak self] result in
            if !result {
                self?.shareCompletionHandler?(.failure(.unknown))
            }
        }
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
            assertionFailure()
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
                assertionFailure()
                oauthCompletionHandler?(.failure(.unknown))
            }
        default:
            assertionFailure()
        }
    }
}

extension QQHandler {

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

        if let pasteboardItems = infos["appsign_redirect_pasteboard"] as? [String: Any] {
            setPasteboard(with: pasteboardItems, in: .general)
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
