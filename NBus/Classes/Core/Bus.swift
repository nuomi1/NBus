//
//  Bus.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/23.
//  Copyright © 2020 nuomi1. All rights reserved.
//

public final class Bus {

    public static let shared = Bus()

    public var handlers: [HandlerType] = []
}

extension Bus {

    public struct ShareOptionKey: RawRepresentable, Hashable {

        public typealias RawValue = String

        public let rawValue: Self.RawValue

        public init(rawValue: Self.RawValue) {
            self.rawValue = rawValue
        }
    }

    public typealias ShareCompletionHandler = (Result<Void, Bus.Error>) -> Void

    public func share(
        message: MessageType,
        to endpoint: Endpoint,
        options: [Bus.ShareOptionKey: Any] = [:],
        completionHandler: @escaping ShareCompletionHandler
    ) {
        let handlers = self.handlers.compactMap { $0 as? ShareHandlerType }

        guard
            let handler = handlers.first(where: { $0.canShare(to: endpoint) })
        else {
            assertionFailure()
            completionHandler(.failure(.missingHandler))
            return
        }

        handler.share(
            message: message,
            to: endpoint,
            options: options,
            completionHandler: completionHandler
        )
    }
}

extension Bus {

    public struct OauthOptionKey: RawRepresentable, Hashable {

        public typealias RawValue = String

        public let rawValue: Self.RawValue

        public init(rawValue: Self.RawValue) {
            self.rawValue = rawValue
        }
    }
}
