//
//  Bus+Message.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/23.
//  Copyright © 2020 nuomi1. All rights reserved.
//

public struct Message: RawRepresentable, Hashable {

    public typealias RawValue = String

    public let rawValue: Self.RawValue

    public init(rawValue: Self.RawValue) {
        self.rawValue = rawValue
    }
}

public enum Messages {

    public static let text = Message(rawValue: "com.nuomi1.bus.message.text")

    public static func text(
        text: String
    ) -> TextMessage {
        TextMessage(
            text: text
        )
    }
}

public protocol MessageType {

    var identifier: Message { get }
}

public protocol MediaMessageType: MessageType {

    var title: String? { get }

    var description: String? { get }

    var thumbnail: Data? { get }
}

public struct TextMessage: MessageType {

    public let identifier = Messages.text

    public let text: String
}
