//
//  QQSDKHandler.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/23.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation

public class QQSDKHandler {

    public let endpoints: [Endpoint] = [
        Endpoints.QQ.friend,
        Endpoints.QQ.timeline,
    ]

    public let platform: Platform = Platforms.qq

    public var isInstalled: Bool {
        QQApiInterface.isQQInstalled()
    }

    private var shareCompletionHandler: Bus.ShareCompletionHandler?
    private var oauthCompletionHandler: Bus.OauthCompletionHandler?

    public let appID: String
    public let universalLink: URL

    public var logHandler: Bus.LogHandler = { message, _, _, _ in
        #if DEBUG
            print(message)
        #endif
    }

    private var coordinator: Coordinator!
    private var oauthCoordinator: TencentOAuth!

    public init(appID: String, universalLink: URL) {
        self.appID = appID
        self.universalLink = universalLink

        coordinator = Coordinator(owner: self)

        #if DEBUG
            QQApiInterface.startLog { [weak self] message in
                guard let message = message else { return }
                self?.log("\(message)")
            }
        #endif

        oauthCoordinator = TencentOAuth(
            appId: appID.trimmingCharacters(in: .letters),
            enableUniveralLink: true,
            universalLink: universalLink.absoluteString,
            delegate: coordinator
        )
    }
}

extension QQSDKHandler: LogHandlerProxyType {}

extension QQSDKHandler: ShareHandlerType {

    // swiftlint:disable cyclomatic_complexity function_body_length

    public func share(
        message: MessageType,
        to endpoint: Endpoint,
        options: [Bus.ShareOptionKey: Any] = [:],
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
                title: message.link.absoluteString,
                description: "",
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
            assertionFailure()
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
            assertionFailure()
            return
        }

        switch code {
        case .EQQAPISENDSUCESS:
            break
        case .EQQAPIMESSAGECONTENTINVALID:
            completionHandler(.failure(.invalidParameter))
        default:
            completionHandler(.failure(.unknown))
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
            assertionFailure()
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
            assertionFailure("\(String(describing: req))")
        }

        func onResp(_ resp: QQBaseResp!) {
            switch resp {
            case let response as SendMessageToQQResp:
                switch response.result {
                case "0":
                    owner?.shareCompletionHandler?(.success(()))
                case "-4":
                    owner?.shareCompletionHandler?(.failure(.userCancelled))
                default:
                    owner?.shareCompletionHandler?(.failure(.unknown))
                }
            default:
                assertionFailure("\(String(describing: resp))")
            }
        }

        func isOnlineResponse(_ response: [AnyHashable: Any]!) {
            assertionFailure("\(String(describing: response))")
        }

        func tencentDidLogin() {
            let parameters = [
                OauthInfoKeys.accessToken: owner?.oauthCoordinator.accessToken,
                OauthInfoKeys.openID: owner?.oauthCoordinator.openId,
            ]
            .bus
            .compactMapContent()

            if !parameters.isEmpty {
                owner?.oauthCompletionHandler?(.success(parameters))
            } else {
                owner?.oauthCompletionHandler?(.failure(.unknown))
            }
        }

        func tencentDidNotLogin(_ cancelled: Bool) {
            if cancelled {
                owner?.oauthCompletionHandler?(.failure(.userCancelled))
            } else {
                owner?.oauthCompletionHandler?(.failure(.unknown))
            }
        }

        func tencentDidNotNetWork() {
            assertionFailure()
        }
    }
}
