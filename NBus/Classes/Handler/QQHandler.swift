//
//  QQHandler.swift
//  NBus
//
//  Created by nuomi1 on 2021/1/4.
//  Copyright © 2021 nuomi1. All rights reserved.
//

import Foundation

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

    private let sdkVersion = "3.5.1"

    @BusUserDefaults(key: ShareOptionKeys.signToken)
    private var signToken: String?

    public init(appID: String, universalLink: URL) {
        self.appID = appID
        self.universalLink = universalLink
    }
}

extension QQHandler: ShareHandlerType {

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
            let identifier = identifier(),
            let displayName = displayName(),
            let cflag = cflag(endpoint, message.identifier),
            let txID = txID()
        else {
            assertionFailure()
            completionHandler(.failure(.invalidMessage))
            return
        }

        shareCompletionHandler = completionHandler

        var urlItems: [String: String] = [:]
        var pasteBoardItems: [String: Any?] = [:]

        urlItems["appsign_txid"] = txID
        urlItems["bundleid"] = identifier
        urlItems["callback_name"] = txID
        urlItems["callback_type"] = "scheme"
        urlItems["cflag"] = cflag
        urlItems["generalpastboard"] = "1"
        urlItems["sdkv"] = sdkVersion
        urlItems["shareType"] = "0"
        urlItems["src_type"] = "app"
        urlItems["thirdAppDisplayName"] = displayName
        urlItems["version"] = "1"

        if let token = signToken {
            urlItems["appsign_token"] = token
        }

        if let oldText = UIPasteboard.general.bus.oldText {
            pasteBoardItems["pasted_string"] = oldText
        }

        if let message = message as? MediaMessageType {
            if let title = message.title?.data(using: .utf8)?.base64EncodedString() {
                urlItems["title"] = title
            }

            if let description = message.description?.data(using: .utf8)?.base64EncodedString() {
                urlItems["description"] = description
            }
        }

        switch message {
        case let message as TextMessage:
            guard
                let text = message.text.data(using: .utf8)?.base64EncodedString()
            else {
                completionHandler(.failure(.invalidMessage))
                return
            }

            urlItems["file_type"] = "text"

            urlItems["file_data"] = text

        case let message as ImageMessage:
            urlItems["file_type"] = "img"

            pasteBoardItems["file_data"] = message.data

        case let message as AudioMessage:
            guard
                let url = message.link.absoluteString.data(using: .utf8)?.base64EncodedString()
            else {
                completionHandler(.failure(.invalidMessage))
                return
            }

            urlItems["file_type"] = "audio"

            urlItems["url"] = url

        case let message as VideoMessage:
            guard
                let url = message.link.absoluteString.data(using: .utf8)?.base64EncodedString()
            else {
                completionHandler(.failure(.invalidMessage))
                return
            }

            urlItems["file_type"] = "video"

            urlItems["url"] = url

        case let message as WebPageMessage:
            guard
                let url = message.link.absoluteString.data(using: .utf8)?.base64EncodedString()
            else {
                completionHandler(.failure(.invalidMessage))
                return
            }

            urlItems["file_type"] = "news"

            urlItems["url"] = url

        case let message as FileMessage:
            urlItems["file_type"] = "localFile"

            if
                let fileName = message.fullName?.data(using: .utf8)?.base64EncodedString() {
                urlItems["fileName"] = fileName
            }

            pasteBoardItems["file_data"] = message.data

        case let message as MiniProgramMessage:
            guard
                let path = message.path.data(using: .utf8)?.base64EncodedString(),
                let url = message.link.absoluteString.data(using: .utf8)?.base64EncodedString()
            else {
                completionHandler(.failure(.invalidMessage))
                return
            }

            urlItems["file_type"] = "news"

            urlItems["url"] = url

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
            urlItems["objectlocation"] = "pasteboard"

            let data = NSKeyedArchiver.archivedData(withRootObject: pbItems)

            UIPasteboard.general.setData(
                data,
                forPasteboardType: "com.tencent.mqq.api.apiLargeData"
            )
        }

        var components = URLComponents()

        components.scheme = "https"
        components.host = "qm.qq.com"
        components.path = "/opensdkul/mqqapi/share/to_fri"

        components.queryItems = urlItems.map { key, value in
            URLQueryItem(name: key, value: value)
        }

        guard let url = components.url else {
            completionHandler(.failure(.invalidMessage))
            return
        }

        guard UIApplication.shared.canOpenURL(url) else {
            completionHandler(.failure(.unknown))
            return
        }

        UIApplication.shared.open(url) { result in
            if !result {
                completionHandler(.failure(.unknown))
            }
        }
    }

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

    private func identifier() -> String? {
        let identifier = Bundle.main.bus.identifier
        return identifier?.data(using: .utf8)?.base64EncodedString()
    }

    private func displayName() -> String? {
        let displayName = Bundle.main.bus.displayName
        return displayName?.data(using: .utf8)?.base64EncodedString()
    }

    private func txID() -> String? {
        let number = appID.trimmingCharacters(in: .letters)
        let txID = String(format: "%08llX", (number as NSString).longLongValue)
        return "QQ\(txID)"
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

        guard
            let identifier = identifier(),
            let txID = txID()
        else {
            assertionFailure()
            completionHandler(.failure(.invalidMessage))
            return
        }

        oauthCompletionHandler = completionHandler

        var urlItems: [String: String] = [:]
        var pasteBoardItems: [String: Any?] = [:]

        pasteBoardItems["app_id"] = appID.trimmingCharacters(in: .letters)
        pasteBoardItems["sdkp"] = "i"
        pasteBoardItems["response_type"] = "token"
        pasteBoardItems["app_name"] = Bundle.main.bus.displayName
        pasteBoardItems["appsign_token"] = ""
        pasteBoardItems["scope"] = "get_user_info"
        pasteBoardItems["bundleid"] = Bundle.main.bus.identifier
        pasteBoardItems["status_version"] = "14"
        pasteBoardItems["sdkv"] = "3.5.1_lite"
        pasteBoardItems["status_machine"] = "iPhone12,1"
        pasteBoardItems["status_os"] = "14.3"
        pasteBoardItems["client_id"] = appID.trimmingCharacters(in: .letters)
        pasteBoardItems["refUniversallink"] = universalLink.absoluteString

        let pbItems = pasteBoardItems.compactMapValues { $0 }
        let data = NSKeyedArchiver.archivedData(withRootObject: pbItems)

        urlItems["pasteboard"] = data.base64EncodedString()

        urlItems["appsign_txid"] = txID
        urlItems["bundleid"] = identifier
        urlItems["sdkv"] = sdkVersion
        urlItems["objectlocation"] = "url"

        var components = URLComponents()

        components.scheme = "https"
        components.host = "qm.qq.com"
        components.path = "/opensdkul/mqqOpensdkSSoLogin/SSoLogin/\(appID)"

        components.queryItems = urlItems.map { key, value in
            URLQueryItem(name: key, value: value)
        }

        guard let url = components.url else {
            completionHandler(.failure(.invalidMessage))
            return
        }

        guard UIApplication.shared.canOpenURL(url) else {
            completionHandler(.failure(.unknown))
            return
        }

        UIApplication.shared.open(url) { result in
            if !result {
                completionHandler(.failure(.unknown))
            }
        }
    }
}

extension QQHandler: OpenURLHandlerType {

    public func openURL(_ url: URL) {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return }

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

extension QQHandler: OpenUserActivityHandlerType {

    public func openUserActivity(_ userActivity: NSUserActivity) {
        guard
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let identifier = Bundle.main.bus.identifier
        else { return }

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
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .base64

        guard
            let item = components.queryItems?.first(where: { $0.name == "appsign_extrainfo" }),
            let itemData = item.value.flatMap({ Data(base64Encoded: $0) }),
            let infos = try? decoder.decode([String: String].self, from: itemData),
            let appSignRedirect = infos["appsign_redirect"],
            let appSignToken = infos["appsign_token"],
            var components = URLComponents(string: appSignRedirect)
        else {
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

        guard
            let url = components.url,
            UIApplication.shared.canOpenURL(url)
        else { return }

        UIApplication.shared.open(url) { [weak self] result in
            if !result {
                self?.shareCompletionHandler?(.failure(.unknown))
            }
        }
    }

    private func handleActionInfo(with components: URLComponents) {
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .base64

        guard
            let item = components.queryItems?.first(where: { $0.name == "sdkactioninfo" }),
            let itemData = item.value.flatMap({ Data(base64Encoded: $0) }),
            let infos = try? decoder.decode([String: String].self, from: itemData)
        else { return }

        var components = URLComponents()

        components.scheme = infos["sdk_action_sheme"]
        components.host = infos["sdk_action_host"]
        components.path = infos["sdk_action_path"] ?? ""
        components.query = infos["sdk_action_query"]

        switch components.host {
        case "response_from_qq":
            handleShare(with: components)
        case "qzapp":
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
            let item = components.queryItems?.first(where: { $0.name == "pasteboard" }),
            let itemData = item.value.flatMap({ Data(base64Encoded: $0) }),
            let infos = NSKeyedUnarchiver.unarchiveObject(with: itemData) as? [String: Any]
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

        public static let accessToken = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.qqHandler.accessToken")

        public static let openID = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.qqHandler.openID")
    }
}
