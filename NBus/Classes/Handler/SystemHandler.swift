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

    public var isSupported: Bool {
        true
    }

    private var oauthCompletionHandler: Bus.OauthCompletionHandler?

    private var boxedCoordinator: Any!

    @available(iOS 13.0, *)
    private var coordinator: Coordinator {
        // swiftlint:disable force_cast
        boxedCoordinator as! Coordinator
        // swiftlint:enable force_cast
    }

    public init() {
        if #available(iOS 13.0, *) {
            boxedCoordinator = Coordinator(owner: self)
        }
    }
}

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
            busAssertionFailure()
            completionHandler(.failure(.invalidParameter))
            return
        }

        guard canShare(message: message.identifier, to: endpoint) else {
            completionHandler(.failure(.unsupportedMessage))
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

        default:
            busAssertionFailure()
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
                busAssertionFailure()
                completionHandler(.failure(.invalidParameter))
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

    private func canShare(message: Message, to endpoint: Endpoint) -> Bool {
        switch endpoint {
        case Endpoints.System.activity:
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
}

extension SystemHandler: OauthHandlerType {

    public func oauth(
        options: [Bus.OauthOptionKey: Any] = [:],
        completionHandler: @escaping Bus.OauthCompletionHandler
    ) {
        guard #available(iOS 13.0, *) else {
            busAssertionFailure()
            completionHandler(.failure(.unknown))
            return
        }

        oauthCompletionHandler = completionHandler

        let provider = ASAuthorizationAppleIDProvider()

        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = coordinator

        controller.performRequests()
    }
}

extension SystemHandler {

    public enum ShareOptionKeys {

        // swiftlint:disable line_length

        public static let presentingViewController = Bus.ShareOptionKey(rawValue: "com.nuomi1.bus.systemHandler.presentingViewController")

        // swiftlint:enable line_length

        public static let sourceView = Bus.ShareOptionKey(rawValue: "com.nuomi1.bus.systemHandler.sourceView")

        public static let sourceRect = Bus.ShareOptionKey(rawValue: "com.nuomi1.bus.systemHandler.sourceRect")
    }
}

extension SystemHandler {

    public enum OauthInfoKeys {

        public static let identityToken = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.systemHandler.identityToken")

        // swiftlint:disable line_length

        public static let authorizationCode = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.systemHandler.authorizationCode")

        // swiftlint:enable line_length

        public static let user = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.systemHandler.user")

        public static let email = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.systemHandler.email")

        public static let givenName = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.systemHandler.givenName")

        public static let familyName = Bus.OauthInfoKey(rawValue: "com.nuomi1.bus.systemHandler.familyName")
    }
}

extension SystemHandler {

    @available(iOS 13.0, *)
    fileprivate class Coordinator: NSObject, ASAuthorizationControllerDelegate {

        weak var owner: SystemHandler?

        required init(owner: SystemHandler) {
            self.owner = owner
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
                .bus
                .compactMapContent()

                if !parameters.isEmpty {
                    owner?.oauthCompletionHandler?(.success(parameters))
                } else {
                    busAssertionFailure()
                    owner?.oauthCompletionHandler?(.failure(.unknown))
                }
            default:
                busAssertionFailure("\(authorization.credential)")
            }
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            switch error {
            case ASAuthorizationError.canceled:
                owner?.oauthCompletionHandler?(.failure(.userCancelled))
            default:
                busAssertionFailure()
                owner?.oauthCompletionHandler?(.failure(.unknown))
            }
        }
    }
}
