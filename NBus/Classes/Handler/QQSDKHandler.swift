//
//  QQSDKHandler.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/23.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation

// swiftlint:disable file_length

public class QQSDKHandler {

    public let endpoints: [Endpoint] = [
        Endpoints.QQ.friend,
        Endpoints.QQ.timeline,
    ]

    public let platform: Platform = Platforms.qq

    public var isInstalled: Bool {
        QQApiInterface.isQQInstalled()
    }

    public var isSupported: Bool {
        true
    }

    private var shareCompletionHandler: Bus.ShareCompletionHandler?
    private var oauthCompletionHandler: Bus.OauthCompletionHandler?
    private var launchCompletionHandler: Bus.LaunchCompletionHandler?

    public let appID: String
    public let universalLink: URL

    private var coordinator: Coordinator!
    private var oauthCoordinator: TencentOAuth!

    private lazy var iso8601DateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter
    }()

    public init(appID: String, universalLink: URL) {
        self.appID = appID
        self.universalLink = universalLink

        coordinator = Coordinator(owner: self)

        oauthCoordinator = TencentOAuth(
            appId: appID.trimmingCharacters(in: .letters),
            enableUniveralLink: true,
            universalLink: universalLink.absoluteString,
            delegate: coordinator
        )
    }
}

extension QQSDKHandler: ShareHandlerType {

    // swiftlint:disable cyclomatic_complexity function_body_length

    public func share(
        message: MessageType,
        to endpoint: Endpoint,
        options: [Bus.ShareOptionKey: Any] = [:],
        completionHandler: @escaping Bus.ShareCompletionHandler
    ) {
        let checkResult = checkShareSupported(message: message, to: endpoint)

        guard case .success = checkResult else {
            completionHandler(checkResult)
            return
        }

        shareCompletionHandler = completionHandler

        let request: SendMessageToQQReq

        switch message {
        case let message as TextMessage:
            let textObject = QQApiTextObject(
                text: message.text
            )

            request = SendMessageToQQReq(content: textObject)

        case let message as ImageMessage:
            let imageObject = QQApiImageObject(
                data: message.data,
                previewImageData: message.thumbnail,
                title: message.title,
                description: message.description
            )

            request = SendMessageToQQReq(content: imageObject)

        case let message as AudioMessage:
            let audioObject = QQApiAudioObject(
                url: message.link,
                title: message.title,
                description: message.description,
                previewImageData: message.thumbnail,
                targetContentType: .audio
            )

            audioObject?.flashURL = message.dataLink

            request = SendMessageToQQReq(content: audioObject)

        case let message as VideoMessage:
            let videoObject = QQApiVideoObject(
                url: message.link,
                title: message.title,
                description: message.description,
                previewImageData: message.thumbnail,
                targetContentType: .video
            )

            request = SendMessageToQQReq(content: videoObject)

        case let message as WebPageMessage:
            let webPageObject = QQApiNewsObject(
                url: message.link,
                title: message.title,
                description: message.description,
                previewImageData: message.thumbnail,
                targetContentType: .news
            )

            request = SendMessageToQQReq(content: webPageObject)

        case let message as FileMessage:
            let fileObject = QQApiFileObject(
                data: message.data,
                previewImageData: message.thumbnail,
                title: message.title,
                description: message.description
            )

            fileObject?.fileName = message.fullName

            request = SendMessageToQQReq(content: fileObject)

        case let message as MiniProgramMessage:
            let webPageObject = QQApiNewsObject(
                url: message.link,
                title: message.title,
                description: message.description,
                previewImageData: message.thumbnail,
                targetContentType: .news
            )

            let miniProgramObject = QQApiMiniProgramObject()

            miniProgramObject.qqApiObject = webPageObject
            miniProgramObject.miniAppID = message.miniProgramID
            miniProgramObject.miniPath = message.path
            miniProgramObject.webpageUrl = message.link.absoluteString
            miniProgramObject.miniprogramType = miniProgramType(message.miniProgramType)

            request = SendMessageToQQReq(miniContent: miniProgramObject)

        default:
            busAssertionFailure()
            completionHandler(.failure(.unsupportedMessage))
            return
        }

        let code: QQApiSendResultCode

        switch endpoint {
        case Endpoints.QQ.friend:
            let cflag = self.cflag(endpoint, message.identifier)
                .reduce(0) { result, flag in result | flag.rawValue }
            request.message?.cflag |= UInt64(cflag)
            code = QQApiInterface.send(request)
        case Endpoints.QQ.timeline:
            code = QQApiInterface.sendReq(toQZone: request)
        default:
            busAssertionFailure()
            completionHandler(.failure(.invalidParameter))
            return
        }

        switch code {
        case .EQQAPISENDSUCESS:
            break
        case .EQQAPIMESSAGECONTENTINVALID:
            completionHandler(.failure(.invalidParameter))
        case .EQQAPIVERSIONNEEDUPDATE:
            completionHandler(.failure(.unsupportedApplication))
        default:
            busAssertionFailure()
            completionHandler(.failure(.unknown))
        }
    }

    // swiftlint:enable cyclomatic_complexity function_body_length

    private func miniProgramType(_ miniProgramType: MiniProgramMessage.MiniProgramType) -> MiniProgramType {
        switch miniProgramType {
        case .release:
            return .online
        case .test:
            return .test
        case .preview:
            return .preview
        }
    }

    private func cflag(_ endpoint: Endpoint, _ message: Message) -> [kQQAPICtrlFlag] {
        var result: [kQQAPICtrlFlag] = []

        switch endpoint {
        case Endpoints.QQ.friend:
            result.append(.qqapiCtrlFlagQZoneShareForbid)

            if message == Messages.file {
                result.append(.qqapiCtrlFlagQQShareDataline)
            }
        default:
            busAssertionFailure()
        }

        return result
    }
}

extension QQSDKHandler: OauthHandlerType {

    public func oauth(
        options: [Bus.OauthOptionKey: Any] = [:],
        completionHandler: @escaping Bus.OauthCompletionHandler
    ) {
        guard isInstalled else {
            completionHandler(.failure(.missingApplication))
            return
        }

        oauthCompletionHandler = completionHandler

        let result = oauthCoordinator.authorize([kOPEN_PERMISSION_GET_USER_INFO])

        if !result {
            completionHandler(.failure(.unknown))
        }
    }
}

extension QQSDKHandler: LaunchHandlerType {

    public func launch(
        program: MiniProgramMessage,
        options: [Bus.LaunchOptionKey: Any],
        completionHandler: @escaping Bus.LaunchCompletionHandler
    ) {
        guard isInstalled else {
            completionHandler(.failure(.missingApplication))
            return
        }

        launchCompletionHandler = completionHandler

        let miniProgramObject = QQApiLaunchMiniProgramObject()

        miniProgramObject.miniAppID = program.miniProgramID
        miniProgramObject.miniPath = program.path
        miniProgramObject.miniprogramType = miniProgramType(program.miniProgramType)

        let request = SendMessageToQQReq(content: miniProgramObject)

        let code = QQApiInterface.send(request)

        switch code {
        case .EQQAPISENDSUCESS:
            break
        case .EQQAPIVERSIONNEEDUPDATE:
            completionHandler(.failure(.unsupportedApplication))
        default:
            busAssertionFailure()
            completionHandler(.failure(.unknown))
        }
    }
}

extension QQSDKHandler: BusQQHandlerHelper {}

extension QQSDKHandler: OpenURLHandlerType {

    public func openURL(_ url: URL) {
        QQApiInterface.handleOpen(url, delegate: coordinator)
        TencentOAuth.handleOpen(url)
    }
}

extension QQSDKHandler: OpenUserActivityHandlerType {

    public func openUserActivity(_ userActivity: NSUserActivity) {
        QQApiInterface.handleOpenUniversallink(userActivity.webpageURL, delegate: coordinator)
        TencentOAuth.handleUniversalLink(userActivity.webpageURL)
    }
}

extension QQSDKHandler {

    public enum OauthInfoKeys {

        public static let accessToken = Bus.OauthInfoKeys.QQ.accessToken

        public static let expirationDate = Bus.OauthInfoKeys.QQ.expirationDate

        public static let openID = Bus.OauthInfoKeys.QQ.openID
    }
}

extension QQSDKHandler {

    fileprivate class Coordinator: NSObject, QQApiInterfaceDelegate, TencentSessionDelegate {

        weak var owner: QQSDKHandler?

        required init(owner: QQSDKHandler) {
            self.owner = owner
        }

        func onReq(_ req: QQBaseReq!) {
            busAssertionFailure("\(String(describing: req))")
        }

        func onResp(_ resp: QQBaseResp!) {
            switch resp {
            case let response as SendMessageToQQResp:
                switch response.result {
                case "0":
                    owner?.shareCompletionHandler?(.success(()))
                case "900101":
                    // msg_body error: url empty or contain illegal char
                    owner?.shareCompletionHandler?(.failure(.invalidParameter))
                case "-4":
                    // the user give up the current operation
                    owner?.shareCompletionHandler?(.failure(.userCancelled))
                case "--100070005":
                    owner?.shareCompletionHandler?(.failure(.invalidParameter))
                case "--1000710008":
                    // 主体信息不一致，无法打开
                    owner?.shareCompletionHandler?(.failure(.invalidParameter))
                default:
                    busAssertionFailure()
                    owner?.shareCompletionHandler?(.failure(.unknown))
                }
            default:
                busAssertionFailure("\(String(describing: resp))")
            }
        }

        func isOnlineResponse(_ response: [AnyHashable: Any]!) {
            busAssertionFailure("\(String(describing: response))")
        }

        func tencentDidLogin() {
            let expirationDate = (owner?.oauthCoordinator.expirationDate).flatMap {
                owner?.iso8601DateFormatter.string(from: $0)
            }

            let parameters = [
                OauthInfoKeys.accessToken: owner?.oauthCoordinator.accessToken,
                OauthInfoKeys.expirationDate: expirationDate,
                OauthInfoKeys.openID: owner?.oauthCoordinator.openId,
            ]
            .bus
            .compactMapContent()

            if !parameters.isEmpty {
                owner?.oauthCompletionHandler?(.success(parameters))
            } else {
                busAssertionFailure()
                owner?.oauthCompletionHandler?(.failure(.unknown))
            }
        }

        func tencentDidNotLogin(_ cancelled: Bool) {
            if cancelled {
                owner?.oauthCompletionHandler?(.failure(.userCancelled))
            } else {
                busAssertionFailure()
                owner?.oauthCompletionHandler?(.failure(.unknown))
            }
        }

        func tencentDidNotNetWork() {
            busAssertionFailure()
        }
    }
}
