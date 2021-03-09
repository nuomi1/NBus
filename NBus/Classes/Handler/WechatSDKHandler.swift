//
//  WechatSDKHandler.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/24.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation

public class WechatSDKHandler {

    public let endpoints: [Endpoint] = [
        Endpoints.Wechat.friend,
        Endpoints.Wechat.timeline,
        Endpoints.Wechat.favorite,
    ]

    public let platform: Platform = Platforms.wechat

    public var isInstalled: Bool {
        WXApi.isWXAppInstalled()
    }

    private var shareCompletionHandler: Bus.ShareCompletionHandler?
    private var oauthCompletionHandler: Bus.OauthCompletionHandler?
    private var launchCompletionHandler: Bus.LaunchCompletionHandler?

    public let appID: String
    public let universalLink: URL

    private var coordinator: Coordinator!

    public init(appID: String, universalLink: URL) {
        self.appID = appID
        self.universalLink = universalLink

        coordinator = Coordinator(owner: self)

        WXApi.registerApp(
            appID,
            universalLink: universalLink.absoluteString
        )
    }
}

extension WechatSDKHandler: ShareHandlerType {

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

        let request = SendMessageToWXReq()
        request.scene = Int32(scene(endpoint).rawValue)

        let mediaMessage = WXMediaMessage()

        if let message = message as? MediaMessageType {
            mediaMessage.title = message.title ?? ""
            mediaMessage.description = message.description ?? ""
            mediaMessage.thumbData = message.thumbnail
        }

        switch message {
        case let message as TextMessage:
            request.text = message.text
            request.bText = true

        case let message as ImageMessage:
            let imageObject = WXImageObject()
            imageObject.imageData = message.data

            mediaMessage.mediaObject = imageObject

        case let message as AudioMessage:
            let audioObject = WXMusicObject()
            audioObject.musicUrl = message.link.absoluteString
            audioObject.musicDataUrl = message.dataLink?.absoluteString ?? ""

            mediaMessage.mediaObject = audioObject

        case let message as VideoMessage:
            let videoObject = WXVideoObject()
            videoObject.videoUrl = message.link.absoluteString

            mediaMessage.mediaObject = videoObject

        case let message as WebPageMessage:
            let webPageObject = WXWebpageObject()
            webPageObject.webpageUrl = message.link.absoluteString

            mediaMessage.mediaObject = webPageObject

        case let message as FileMessage:
            let fileObject = WXFileObject()
            fileObject.fileData = message.data
            fileObject.fileExtension = message.fileExtension

            mediaMessage.mediaObject = fileObject

        case let message as MiniProgramMessage:
            let miniProgramObject = WXMiniProgramObject()
            miniProgramObject.webpageUrl = message.link.absoluteString
            miniProgramObject.userName = message.miniProgramID
            miniProgramObject.path = message.path
            miniProgramObject.miniProgramType = miniProgramType(message.miniProgramType)
            miniProgramObject.hdImageData = message.thumbnail

            mediaMessage.mediaObject = miniProgramObject

        default:
            busAssertionFailure()
            completionHandler(.failure(.unsupportedMessage))
            return
        }

        request.message = mediaMessage

        WXApi.send(request) { result in
            if !result {
                completionHandler(.failure(.unknown))
            }
        }
    }

    // swiftlint:enable cyclomatic_complexity function_body_length

    private func canShare(message: Message, to endpoint: Endpoint) -> Bool {
        switch endpoint {
        case Endpoints.Wechat.friend:
            return [
                Messages.text,
                Messages.image,
                Messages.audio,
                Messages.video,
                Messages.webPage,
                Messages.file,
                Messages.miniProgram,
            ].contains(message)
        case Endpoints.Wechat.timeline:
            return [
                Messages.text,
                Messages.image,
                Messages.audio,
                Messages.video,
                Messages.webPage,
            ].contains(message)
        case Endpoints.Wechat.favorite:
            return [
                Messages.text,
                Messages.image,
                Messages.audio,
                Messages.video,
                Messages.webPage,
                Messages.file,
            ].contains(message)
        default:
            busAssertionFailure()
            return false
        }
    }

    private func scene(_ endpoint: Endpoint) -> WXScene {
        switch endpoint {
        case Endpoints.Wechat.friend:
            return WXSceneSession
        case Endpoints.Wechat.timeline:
            return WXSceneTimeline
        case Endpoints.Wechat.favorite:
            return WXSceneFavorite
        default:
            busAssertionFailure()
            return WXSceneSession
        }
    }

    private func miniProgramType(_ miniProgramType: MiniProgramMessage.MiniProgramType) -> WXMiniProgramType {
        switch miniProgramType {
        case .release:
            return .release
        case .test:
            return .test
        case .preview:
            return .preview
        }
    }
}

extension WechatSDKHandler: OauthHandlerType {

    public func oauth(
        options: [Bus.OauthOptionKey: Any] = [:],
        completionHandler: @escaping Bus.OauthCompletionHandler
    ) {
        guard isInstalled else {
            completionHandler(.failure(.missingApplication))
            return
        }

        oauthCompletionHandler = completionHandler

        let request = SendAuthReq()
        request.scope = "snsapi_userinfo"

        WXApi.send(request) { result in
            if !result {
                completionHandler(.failure(.unknown))
            }
        }
    }
}

extension WechatSDKHandler: LaunchHandlerType {

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

        let request = WXLaunchMiniProgramReq()

        request.userName = program.miniProgramID
        request.path = program.path
        request.miniProgramType = miniProgramType(program.miniProgramType)

        WXApi.send(request) { result in
            if !result {
                completionHandler(.failure(.unknown))
            }
        }
    }
}

extension WechatSDKHandler: OpenURLHandlerType {

    public func openURL(_ url: URL) {
        WXApi.handleOpen(url, delegate: coordinator)
    }
}

extension WechatSDKHandler: OpenUserActivityHandlerType {

    public func openUserActivity(_ userActivity: NSUserActivity) {
        WXApi.handleOpenUniversalLink(userActivity, delegate: coordinator)
    }
}

extension WechatSDKHandler {

    public enum OauthInfoKeys {

        public static let code = Bus.OauthInfoKeys.Wechat.code
    }
}

extension WechatSDKHandler {

    fileprivate class Coordinator: NSObject, WXApiDelegate {

        weak var owner: WechatSDKHandler?

        required init(owner: WechatSDKHandler) {
            self.owner = owner
        }

        func onReq(_ req: BaseReq) {
            busAssertionFailure("\(req)")
        }

        func onResp(_ resp: BaseResp) {
            switch resp {
            case let response as SendMessageToWXResp:
                switch response.errCode {
                case WXSuccess.rawValue:
                    owner?.shareCompletionHandler?(.success(()))
                case WXErrCodeUserCancel.rawValue:
                    owner?.shareCompletionHandler?(.failure(.userCancelled))
                default:
                    busAssertionFailure()
                    owner?.shareCompletionHandler?(.failure(.unknown))
                }
            case let response as SendAuthResp:
                switch response.errCode {
                case WXSuccess.rawValue:
                    let parameters = [
                        OauthInfoKeys.code: response.code,
                    ]
                    .bus
                    .compactMapContent()

                    if !parameters.isEmpty {
                        owner?.oauthCompletionHandler?(.success(parameters))
                    } else {
                        busAssertionFailure()
                        owner?.oauthCompletionHandler?(.failure(.unknown))
                    }
                case WXErrCodeCommon.rawValue:
                    owner?.oauthCompletionHandler?(.failure(.invalidParameter))
                case WXErrCodeAuthDeny.rawValue,
                     WXErrCodeUserCancel.rawValue:
                    owner?.oauthCompletionHandler?(.failure(.userCancelled))
                default:
                    busAssertionFailure()
                    owner?.oauthCompletionHandler?(.failure(.unknown))
                }
            case let response as WXLaunchMiniProgramResp:
                switch response.errCode {
                case WXSuccess.rawValue:
                    owner?.launchCompletionHandler?(.success(()))
                case WXErrCodeSentFail.rawValue:
                    owner?.launchCompletionHandler?(.failure(.invalidParameter))
                case WXErrCodeUserCancel.rawValue:
                    owner?.launchCompletionHandler?(.failure(.userCancelled))
                default:
                    busAssertionFailure()
                    owner?.launchCompletionHandler?(.failure(.unknown))
                }
            default:
                busAssertionFailure("\(resp)")
            }
        }
    }
}
