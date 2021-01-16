//
//  Bus+Message.swift
//  NBus
//
//  Created by nuomi1 on 2020/8/23.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation

public struct Message: RawRepresentable, Hashable {

    public typealias RawValue = String

    public let rawValue: Self.RawValue

    public init(rawValue: Self.RawValue) {
        self.rawValue = rawValue
    }
}

public enum Messages {

    public static let text = Message(rawValue: "com.nuomi1.bus.message.text")

    public static let image = Message(rawValue: "com.nuomi1.bus.message.image")

    public static let audio = Message(rawValue: "com.nuomi1.bus.message.audio")

    public static let video = Message(rawValue: "com.nuomi1.bus.message.video")

    public static let webPage = Message(rawValue: "com.nuomi1.bus.message.webPage")

    public static let file = Message(rawValue: "com.nuomi1.bus.message.file")

    public static let miniProgram = Message(rawValue: "com.nuomi1.bus.message.miniProgram")

    public static func text(
        text: String
    ) -> TextMessage {
        TextMessage(
            text: text
        )
    }

    public static func image(
        data: Data,
        title: String? = nil,
        description: String? = nil,
        thumbnail: Data? = nil
    ) -> ImageMessage {
        ImageMessage(
            data: data,
            title: title,
            description: description,
            thumbnail: thumbnail
        )
    }

    public static func audio(
        link: URL,
        dataLink: URL? = nil,
        title: String? = nil,
        description: String? = nil,
        thumbnail: Data? = nil
    ) -> AudioMessage {
        AudioMessage(
            link: link,
            dataLink: dataLink,
            title: title,
            description: description,
            thumbnail: thumbnail
        )
    }

    public static func video(
        link: URL,
        title: String? = nil,
        description: String? = nil,
        thumbnail: Data? = nil
    ) -> VideoMessage {
        VideoMessage(
            link: link,
            title: title,
            description: description,
            thumbnail: thumbnail
        )
    }

    public static func webPage(
        link: URL,
        title: String? = nil,
        description: String? = nil,
        thumbnail: Data? = nil
    ) -> WebPageMessage {
        WebPageMessage(
            link: link,
            title: title,
            description: description,
            thumbnail: thumbnail
        )
    }

    public static func file(
        data: Data,
        fileExtension: String,
        fileName: String? = nil,
        title: String? = nil,
        description: String? = nil,
        thumbnail: Data? = nil
    ) -> FileMessage {
        FileMessage(
            data: data,
            fileExtension: fileExtension,
            fileName: fileName,
            title: title,
            description: description,
            thumbnail: thumbnail
        )
    }

    public static func miniProgram(
        miniProgramID: String,
        path: String,
        link: URL,
        miniProgramType: MiniProgramMessage.MiniProgramType,
        thumbnail: Data? = nil
    ) -> MiniProgramMessage {
        MiniProgramMessage(
            miniProgramID: miniProgramID,
            path: path,
            link: link,
            miniProgramType: miniProgramType,
            thumbnail: thumbnail
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

public struct ImageMessage: MediaMessageType {

    public let identifier = Messages.image

    public let data: Data

    public let title: String?

    public let description: String?

    public let thumbnail: Data?
}

public struct AudioMessage: MediaMessageType {

    public let identifier = Messages.audio

    public let link: URL

    public let dataLink: URL?

    public let title: String?

    public let description: String?

    public let thumbnail: Data?
}

public struct VideoMessage: MediaMessageType {

    public let identifier = Messages.video

    public let link: URL

    public let title: String?

    public let description: String?

    public let thumbnail: Data?
}

public struct WebPageMessage: MediaMessageType {

    public let identifier = Messages.webPage

    public let link: URL

    public let title: String?

    public let description: String?

    public let thumbnail: Data?
}

public struct FileMessage: MediaMessageType {

    public let identifier = Messages.file

    public let data: Data

    public let fileExtension: String

    public let fileName: String?

    public let title: String?

    public let description: String?

    public let thumbnail: Data?

    public var fullName: String? {
        fileName.map { "\($0).\(fileExtension)" }
    }
}

public struct MiniProgramMessage: MessageType {

    public enum MiniProgramType {
        case release
        case test
        case preview
    }

    public let identifier = Messages.miniProgram

    public let miniProgramID: String

    public let path: String

    public let link: URL

    public let miniProgramType: MiniProgramType

    public let thumbnail: Data?
}
