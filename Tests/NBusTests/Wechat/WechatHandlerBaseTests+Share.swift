//
//  WechatHandlerBaseTests+Share.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import XCTest

// MARK: - Share

extension WechatHandlerBaseTests: ShareTestCase {

    func test_share_text_friend() {
        test_share(MediaSource.text, Endpoints.Wechat.friend)
    }

    func test_share_text_timeline() {
        test_share(MediaSource.text, Endpoints.Wechat.timeline)
    }

    func test_share_text_favorite() {
        test_share(MediaSource.text, Endpoints.Wechat.favorite)
    }

    func test_share_image_friend() {
        test_share(MediaSource.wechatImage, Endpoints.Wechat.friend)
    }

    func test_share_image_timeline() {
        test_share(MediaSource.wechatImage, Endpoints.Wechat.timeline)
    }

    func test_share_image_favorite() {
        test_share(MediaSource.wechatImage, Endpoints.Wechat.favorite)
    }

    func test_share_audio_friend() {
        test_share(MediaSource.audio, Endpoints.Wechat.friend)
    }

    func test_share_audio_timeline() {
        test_share(MediaSource.audio, Endpoints.Wechat.timeline)
    }

    func test_share_audio_favorite() {
        test_share(MediaSource.audio, Endpoints.Wechat.favorite)
    }

    func test_share_video_friend() {
        test_share(MediaSource.video, Endpoints.Wechat.friend)
    }

    func test_share_video_timeline() {
        test_share(MediaSource.video, Endpoints.Wechat.timeline)
    }

    func test_share_video_favorite() {
        test_share(MediaSource.video, Endpoints.Wechat.favorite)
    }

    func test_share_webPage_friend() {
        test_share(MediaSource.webPage, Endpoints.Wechat.friend)
    }

    func test_share_webPage_timeline() {
        test_share(MediaSource.webPage, Endpoints.Wechat.timeline)
    }

    func test_share_webPage_favorite() {
        test_share(MediaSource.webPage, Endpoints.Wechat.favorite)
    }

    func test_share_file_friend() {
        test_share(MediaSource.file, Endpoints.Wechat.friend)
    }

    func test_share_file_timeline() {
        test_share(MediaSource.file, Endpoints.Wechat.timeline)
    }

    func test_share_file_favorite() {
        test_share(MediaSource.file, Endpoints.Wechat.favorite)
    }

    func test_share_miniProgram_friend() {
        test_share(MediaSource.wechatMiniProgram, Endpoints.Wechat.friend)
    }

    func test_share_miniProgram_timeline() {
        test_share(MediaSource.wechatMiniProgram, Endpoints.Wechat.timeline)
    }

    func test_share_miniProgram_favorite() {
        test_share(MediaSource.wechatMiniProgram, Endpoints.Wechat.favorite)
    }
}

// MARK: - Share - Message - Scheme

extension WechatHandlerBaseTests: ShareMessageSchemeTestCase {

    func report_share_scheme(_ message: MessageType, _ endpoint: Endpoint) -> Set<String> {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage,
             is MiniProgramMessage:
            return []
        default:
            fatalError()
        }
    }
}

// MARK: - Share - Message - UniversalLink - Request

extension WechatHandlerBaseTests: ShareMessageUniversalLinkRequestTestCase {

    func test_share_ul_request(path: String) {
        XCTAssertEqual(path, "/app/\(appID)/sendreq/")
    }

    func test_share_ul_request(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint) {
        XCTAssertTrue(true)
    }
}

// MARK: - Share - Message - Pasteboard - Request

extension WechatHandlerBaseTests: ShareMessagePasteboardRequestTestCase {

    func test_share_pb_request(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        let appBrandPath = dictionary.removeValue(forKey: "appBrandPath") as? String
        test_appBrandPath(appBrandPath, message)

        let appBrandUserName = dictionary.removeValue(forKey: "appBrandUserName") as? String
        test_appBrandUserName(appBrandUserName, message)

        let appbrandissecrectmessage = dictionary.removeValue(forKey: "appbrandissecrectmessage") as? Bool
        test_appbrandissecrectmessage(appbrandissecrectmessage, message)

        let appbrandisupdatablemessage = dictionary.removeValue(forKey: "appbrandisupdatablemessage") as? Bool
        test_appbrandisupdatablemessage(appbrandisupdatablemessage, message)

        let command = dictionary.removeValue(forKey: "command") as! String
        test_command(command, message)

        let description = dictionary.removeValue(forKey: "description") as? String
        test_description(description, message)

        let disableForward = dictionary.removeValue(forKey: "disableForward") as? Bool
        test_disableForward(disableForward, message)

        let fileData = dictionary.removeValue(forKey: "fileData") as? Data
        test_fileData(fileData, message)

        let fileExt = dictionary.removeValue(forKey: "fileExt") as? String
        test_fileExt(fileExt, message)

        let hdThumbData = dictionary.removeValue(forKey: "hdThumbData") as? Data
        test_hdThumbData(hdThumbData, message)

        let mediaDataUrl = dictionary.removeValue(forKey: "mediaDataUrl") as? String
        test_mediaDataUrl(mediaDataUrl, message)

        let mediaUrl = dictionary.removeValue(forKey: "mediaUrl") as? String
        test_mediaUrl(mediaUrl, message)

        let miniprogramType = dictionary.removeValue(forKey: "miniprogramType") as? Int
        test_miniprogramType(miniprogramType, message)

        let musicVideoDuration = dictionary.removeValue(forKey: "musicVideoDuration") as? String
        test_musicVideoDuration(musicVideoDuration, message)

        let musicVideoIssueData = dictionary.removeValue(forKey: "musicVideoIssueData") as? String
        test_musicVideoIssueData(musicVideoIssueData, message)

        let objectType = dictionary.removeValue(forKey: "objectType") as? String
        test_objectType(objectType, message)

        let scene = dictionary.removeValue(forKey: "scene") as! String
        test_scene(scene, endpoint)

        let thumbData = dictionary.removeValue(forKey: "thumbData") as? Data
        test_thumbData(thumbData, message)

        let title = dictionary.removeValue(forKey: "title") as! String
        test_title(title, message)

        let weworkObjectSubType = dictionary.removeValue(forKey: "weworkObjectSubType") as? String
        test_weworkObjectSubType(weworkObjectSubType, message)

        let withShareTicket = dictionary.removeValue(forKey: "withShareTicket") as? Bool
        test_withShareTicket(withShareTicket, message)
    }
}

extension WechatHandlerBaseTests {

    func test_appBrandPath(_ value: String?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage:
            XCTAssertNil(value)
        case let message as MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.path)
        default:
            fatalError()
        }
    }

    func test_appBrandUserName(_ value: String?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage:
            XCTAssertNil(value)
        case let message as MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.miniProgramID)
        default:
            fatalError()
        }
    }

    func test_appbrandissecrectmessage(_ value: Bool?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(value)
        case is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage,
             is MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(value), false)
        default:
            fatalError()
        }
    }

    func test_appbrandisupdatablemessage(_ value: Bool?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(value)
        case is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage,
             is MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(value), false)
        default:
            fatalError()
        }
    }

    func test_command(_ value: String, _ message: MessageType) {
        switch message.identifier {
        case Messages.text:
            XCTAssertEqual(value, "1020")
        case Messages.image,
             Messages.audio,
             Messages.video,
             Messages.webPage,
             Messages.file,
             Messages.miniProgram:
            XCTAssertEqual(value, "1010")
        default:
            fatalError()
        }
    }

    func test_description(_ value: String?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(value)
        case let message as ImageMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.description)
        case let message as AudioMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.description)
        case let message as VideoMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.description)
        case let message as WebPageMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.description)
        case let message as FileMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.description)
        case let message as MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.description)
        default:
            fatalError()
        }
    }

    func test_disableForward(_ value: Bool?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(value)
        case is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage,
             is MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(value), false)
        default:
            fatalError()
        }
    }

    func test_fileData(_ value: Data?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is MiniProgramMessage:
            XCTAssertNil(value)
        case let message as ImageMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.data)
        case let message as FileMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.data)
        default:
            fatalError()
        }
    }

    func test_fileExt(_ value: String?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is MiniProgramMessage:
            XCTAssertNil(value)
        case let message as FileMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.fileExtension)
        default:
            fatalError()
        }
    }

    func test_hdThumbData(_ value: Data?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage:
            XCTAssertNil(value)
        case let message as MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.thumbnail)
        default:
            fatalError()
        }
    }

    func test_mediaDataUrl(_ value: String?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage,
             is MiniProgramMessage:
            XCTAssertNil(value)
        case let message as AudioMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.dataLink?.absoluteString)
        default:
            fatalError()
        }
    }

    func test_mediaUrl(_ value: String?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is FileMessage:
            XCTAssertNil(value)
        case let message as AudioMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.link.absoluteString)
        case let message as VideoMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.link.absoluteString)
        case let message as WebPageMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.link.absoluteString)
        case let message as MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.link.absoluteString)
        default:
            fatalError()
        }
    }

    func test_miniprogramType(_ value: Int?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(value)
        case is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage,
             is MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(value), 0)
        default:
            fatalError()
        }
    }

    func test_musicVideoDuration(_ value: String?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(value)
        case is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage,
             is MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(value), "0")
        default:
            fatalError()
        }
    }

    func test_musicVideoIssueData(_ value: String?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(value)
        case is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage,
             is MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(value), "0")
        default:
            fatalError()
        }
    }

    func test_objectType(_ value: String?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(value)
        case is ImageMessage:
            XCTAssertEqual(try XCTUnwrap(value), "2")
        case is AudioMessage:
            XCTAssertEqual(try XCTUnwrap(value), "3")
        case is VideoMessage:
            XCTAssertEqual(try XCTUnwrap(value), "4")
        case is WebPageMessage:
            XCTAssertEqual(try XCTUnwrap(value), "5")
        case is FileMessage:
            XCTAssertEqual(try XCTUnwrap(value), "6")
        case is MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(value), "36")
        default:
            fatalError()
        }
    }

    func test_scene(_ value: String, _ endpoint: Endpoint) {
        switch endpoint {
        case Endpoints.Wechat.friend:
            XCTAssertEqual(value, "0")
        case Endpoints.Wechat.timeline:
            XCTAssertEqual(value, "1")
        case Endpoints.Wechat.favorite:
            XCTAssertEqual(value, "2")
        default:
            fatalError()
        }
    }

    func test_thumbData(_ value: Data?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(value)
        case let message as ImageMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.thumbnail)
        case let message as AudioMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.thumbnail)
        case let message as VideoMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.thumbnail)
        case let message as WebPageMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.thumbnail)
        case let message as FileMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.thumbnail)
        case let message as MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.thumbnail)
        default:
            fatalError()
        }
    }

    func test_title(_ value: String, _ message: MessageType) {
        switch message {
        case let message as TextMessage:
            XCTAssertEqual(value, message.text)
        case let message as ImageMessage:
            XCTAssertEqual(value, message.title)
        case let message as AudioMessage:
            XCTAssertEqual(value, message.title)
        case let message as VideoMessage:
            XCTAssertEqual(value, message.title)
        case let message as WebPageMessage:
            XCTAssertEqual(value, message.title)
        case let message as FileMessage:
            XCTAssertEqual(value, message.title)
        case let message as MiniProgramMessage:
            XCTAssertEqual(value, message.title)
        default:
            fatalError()
        }
    }

    func test_weworkObjectSubType(_ value: String?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(value)
        case is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage,
             is MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(value), "0")
        default:
            fatalError()
        }
    }

    func test_withShareTicket(_ value: Bool?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(value)
        case is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage,
             is MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(value), false)
        default:
            fatalError()
        }
    }
}
