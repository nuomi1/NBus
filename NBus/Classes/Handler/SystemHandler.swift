//
//  SystemHandler.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/24.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation

public class SystemHandler {

    public let endpoints: [Endpoint] = [
        Endpoints.System.activity,
    ]

    public var isInstalled: Bool {
        true
    }

    public var logHandler: (String, String, String, UInt) -> Void = { message, _, _, _ in
        #if DEBUG
            print(message)
        #endif
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
            let rootViewController = UIApplication.shared.keyWindow?.rootViewController
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

        rootViewController.present(
            activityViewController,
            animated: true
        )
    }

    // swiftlint:enable cyclomatic_complexity function_body_length
}

extension SystemHandler {

    public enum ShareOptionKeys {

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
