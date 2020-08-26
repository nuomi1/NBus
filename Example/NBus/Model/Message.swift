//
//  Message.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import Foundation
import NBus

extension Messages {

    static let gif = Message(rawValue: "com.nuomi1.bus.mock.message.gif")
}

extension Message: CustomStringConvertible {

    public var description: String {
        switch self {
        case Messages.text:
            return "文本"
        case Messages.image:
            return "图片"
        case Messages.gif:
            return "GIF"
        case Messages.audio:
            return "音乐"
        case Messages.video:
            return "视频"
        case Messages.webPage:
            return "网页"
        case Messages.file:
            return "文件"
        case Messages.miniProgram:
            return "小程序"
        default:
            assertionFailure()
            return "unknown"
        }
    }
}

extension Message {

    static let allCases: [Message] = [
        Messages.text,
        Messages.image,
        Messages.gif,
        Messages.audio,
        Messages.video,
        Messages.webPage,
        Messages.file,
        Messages.miniProgram,
    ]
}
