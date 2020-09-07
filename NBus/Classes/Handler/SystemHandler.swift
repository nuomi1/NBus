//
//  SystemHandler.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/24.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import AuthenticationServices
import Foundation

public class SystemHandler {

    public let endpoints: [Endpoint] = [
        Endpoints.System.activity,
    ]

    public let platform: Platform = Platforms.system

    public var isInstalled: Bool {
        true
    }

    private var oauthCompletionHandler: Bus.OauthCompletionHandler?

    public var logHandler: Bus.LogHandler = { message, _, _, _ in
        #if DEBUG
            print(message)
        #endif
    }

    private var boxHelper: Any!

    @available(iOS 13.0, *)
    private var helper: Helper {
        // swiftlint:disable force_cast
        boxHelper as! Helper
        // swiftlint:enable force_cast
    }

    public init() {
        if #available(iOS 13.0, *) {
            boxHelper = Helper(master: self)
        }
    }
}

extension SystemHandler: LogHandlerProxyType {}

extension SystemHandler: ShareHandlerType {

    // swiftlint:disable cyclomatic_complexity function_body_length

    public func share(
        message: MessageType,
        to endpoint: Endpoint,
        options: [Bus.ShareOptionKey: Any] = [:],
        completionHandler: @escaping Bus.ShareCompletionHandler
    ) {
        guard
            let presentingViewController = options[ShareOptionKeys.presentingViewController] as? UIViewController
            ?? UIApplication.shared.keyWindow?.rootViewController
        else {
            assertionFailure()
            completionHandler(.failure(.unknown))
            return
        }

        var activityItems: [Any?] = []

        if let message = message as? MediaMessageType {
            activityItems.append(message.title)
            activityItems.append(message.description)
        }

        switch message {
        case let message as TextMessage:
            activityItems.append(message.text)

        case let message as ImageMessage:
            activityItems.append(message.data)

        case let message as AudioMessage:
            activityItems.append(message.link)

        case let message as VideoMessage:
            activityItems.append(message.link)

        case let message as WebPageMessage:
            activityItems.append(message.link)

        case let message as FileMessage:
            activityItems.append(message.data)

        case let message as MiniProgramMessage:
            activityItems.append(message.link)

        default:
            completionHandler(.failure(.unsupportedMessage))
            return
        }

        let activityViewController = UIActivityViewController(
            activityItems: activityItems.compactMap { $0 },
            applicationActivities: nil
        )

        activityViewController.completionWithItemsHandler = { _, result, _, error in
            switch (result, error) {
            case (_, _?):
                completionHandler(.failure(.unknown))
            case (true, _):
                completionHandler(.success(()))
            case (false, _):
                completionHandler(.failure(.userCancelled))
            }
        }

        if let popoverPresentationController = activityViewController.popoverPresentationController {
            guard
                let sourceView = options[ShareOptionKeys.sourceView] as? UIView
            else {
                assertionFailure()
                completionHandler(.failure(.unknown))
                return
            }

            popoverPresentationController.sourceView = sourceView

            if let sourceRect = options[ShareOptionKeys.sourceRect] as? CGRect {
                popoverPresentationController.sourceRect = sourceRect
            }
        }

        presentingViewController.present(
            activityViewController,
            animated: true
        )
    }

    // swiftlint:enable cyclomatic_complexity function_body_length
}

extension SystemHandler: OauthHandlerType {

    public func oauth(
        options: [Bus.OauthOptionKey: Any] = [:],
        completionHandler: @escaping Bus.OauthCompletionHandler
    ) {
        guard #available(iOS 13.0, *) else {
            completionHandler(.failure(.unknown))
            return
        }

        oauthCompletionHandler = completionHandler

        let provider = ASAuthorizationAppleIDProvider()

        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = helper

        controller.performRequests()
    }
}

extension SystemHandler {

    public enum ShareOptionKeys {

        public static let presentingViewController = Bus.ShareOptionKey(rawValue: "com.nuomi1.bus.systemHandler.presentingViewController")

        public static let sourceView = Bus.ShareOptionKey(rawValue: "com.nuomi1.bus.systemHandler.sourceView")

        public static let sourceRect = Bus.ShareOptionKey(rawValue: "com.nuomi1.bus.systemHandler.sourceRect")
    }
}

extension SystemHandler {

    public enum OauthInfoKeys {

        public static let identityToken = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.systemHandler.identityToken")

        public static let authorizationCode = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.systemHandler.authorizationCode")

        public static let user = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.systemHandler.user")

        public static let email = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.systemHandler.email")

        public static let givenName = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.systemHandler.givenName")

        public static let familyName = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.systemHandler.familyName")
    }
}

extension SystemHandler {

    @available(iOS 13.0, *)
    fileprivate class Helper: NSObject, ASAuthorizationControllerDelegate {

        weak var master: SystemHandler?

        required init(master: SystemHandler) {
            self.master = master
        }

        func authorizationController(
            controller: ASAuthorizationController,
            didCompleteWithAuthorization authorization: ASAuthorization
        ) {
            switch authorization.credential {
            case let credential as ASAuthorizationAppleIDCredential:
                let identityToken = credential.identityToken.flatMap {
                    String(data: $0, encoding: .utf8)
                }

                let authorizationCode = credential.authorizationCode.flatMap {
                    String(data: $0, encoding: .utf8)
                }

                let parameters = [
                    OauthInfoKeys.identityToken: identityToken,
                    OauthInfoKeys.authorizationCode: authorizationCode,
                    OauthInfoKeys.user: credential.user,
                    OauthInfoKeys.email: credential.email,
                    OauthInfoKeys.givenName: credential.fullName?.givenName,
                    OauthInfoKeys.familyName: credential.fullName?.familyName,
                ]
                .compactMapValues { value -> String? in
                    guard
                        let value = value, !value.isEmpty
                    else { return nil }

                    return value
                }

                master?.oauthCompletionHandler?(.success(parameters))
            default:
                assertionFailure("\(authorization.credential)")
            }
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            switch error {
            case ASAuthorizationError.canceled:
                master?.oauthCompletionHandler?(.failure(.userCancelled))
            default:
                master?.oauthCompletionHandler?(.failure(.unknown))
            }
        }
    }
}
