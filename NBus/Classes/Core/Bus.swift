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
}
