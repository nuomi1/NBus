//
//  QQHandlerBaseTests+Share.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import XCTest

// MARK: - Share

extension QQHandlerBaseTests: ShareTestCase {

    func test_share_text_friend() {
        test_share(MediaSource.text, Endpoints.QQ.friend)
    }

    func test_share_text_timeline() {
        test_share(MediaSource.text, Endpoints.QQ.timeline)
    }

    func test_share_image_friend() {
        test_share(MediaSource.qqImage, Endpoints.QQ.friend)
    }

    func test_share_image_timeline() {
        test_share(MediaSource.qqImage, Endpoints.QQ.timeline)
    }

    func test_share_audio_friend() {
        test_share(MediaSource.audio, Endpoints.QQ.friend)
    }

    func test_share_audio_timeline() {
        test_share(MediaSource.text, Endpoints.QQ.timeline)
    }

    func test_share_video_friend() {
        test_share(MediaSource.video, Endpoints.QQ.friend)
    }

    func test_share_video_timeline() {
        test_share(MediaSource.text, Endpoints.QQ.timeline)
    }

    func test_share_webPage_friend() {
        test_share(MediaSource.webPage, Endpoints.QQ.friend)
    }

    func test_share_webPage_timeline() {
        test_share(MediaSource.webPage, Endpoints.QQ.timeline)
    }

    func test_share_file_friend() {
        test_share(MediaSource.file, Endpoints.QQ.friend)
    }

    func test_share_file_timeline() {
        test_share(MediaSource.file, Endpoints.QQ.timeline)
    }

    func test_share_miniProgram_friend() {
        test_share(MediaSource.qqMiniProgram, Endpoints.QQ.friend)
    }

    func test_share_miniProgram_timeline() {
        test_share(MediaSource.webPage, Endpoints.QQ.timeline)
    }
}

// MARK: - Share - Message - Scheme

extension QQHandlerBaseTests: ShareMessageSchemeTestCase {

    func report_share_scheme(_ message: MessageType, _ endpoint: Endpoint) -> Set<String> {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is FileMessage:
            return []
        case is WebPageMessage:
            return [
                "mqqopensdknopasteboard",
            ]
        case is MiniProgramMessage:
            return [
                "mqqopensdkminiapp",
                "mqqopensdknopasteboard",
            ]
        default:
            XCTAssertTrue(false)
            return []
        }
    }
}

// MARK: - Share - Common - UniversalLink

extension QQHandlerBaseTests: ShareCommonUniversalLinkTestCase {

    func test_share_common_ul(path: String) {
        XCTAssertEqual(path, "/opensdkul/mqqapi/share/to_fri")
    }

    func test_share_common_ul(queryItems: inout [URLQueryItem]) {
        let callback_name = queryItems.removeFirst { $0.name == "callback_name" }!
        test_callback_name(callback_name)

        let callback_type = queryItems.removeFirst { $0.name == "callback_type" }!
        test_callback_type(callback_type)

        let src_type = queryItems.removeFirst { $0.name == "src_type" }!
        test_src_type(src_type)

        let thirdAppDisplayName = queryItems.removeFirst { $0.name == "thirdAppDisplayName" }!
        test_thirdAppDisplayName(thirdAppDisplayName)

        let version = queryItems.removeFirst { $0.name == "version" }!
        test_version(version)
    }
}

extension QQHandlerBaseTests {

    func test_callback_name(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, txID)
    }

    func test_callback_type(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, "scheme")
    }

    func test_src_type(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, "app")
    }

    func test_thirdAppDisplayName(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, displayName.bus.base64EncodedString)
    }

    func test_version(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, "1")
    }
}

// MARK: - Share - MediaMessage - UniversalLink

extension QQHandlerBaseTests: ShareMediaMessageUniversalLinkTestCase {

    func test_share_media_ul(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint) {
        let description = queryItems.removeFirst { $0.name == "description" }
        test_description(description, message)

        let title = queryItems.removeFirst { $0.name == "title" }
        test_title(title, message)
    }
}

extension QQHandlerBaseTests {

    func test_description(_ queryItem: URLQueryItem?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(queryItem)
        case let message as ImageMessage:
            XCTAssertEqual(queryItem!.value!, message.description?.bus.base64EncodedString)
        case let message as AudioMessage:
            XCTAssertEqual(queryItem!.value!, message.description?.bus.base64EncodedString)
        case let message as VideoMessage:
            XCTAssertEqual(queryItem!.value!, message.description?.bus.base64EncodedString)
        case let message as WebPageMessage:
            XCTAssertEqual(queryItem!.value!, message.description?.bus.base64EncodedString)
        case let message as FileMessage:
            XCTAssertEqual(queryItem!.value!, message.description?.bus.base64EncodedString)
        case let message as MiniProgramMessage:
            XCTAssertEqual(queryItem!.value!, message.description?.bus.base64EncodedString)
        default:
            XCTAssertTrue(false, String(describing: queryItem?.value))
        }
    }

    func test_title(_ queryItem: URLQueryItem?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(queryItem)
        case let message as ImageMessage:
            XCTAssertEqual(queryItem!.value!, message.title?.bus.base64EncodedString)
        case let message as AudioMessage:
            XCTAssertEqual(queryItem!.value!, message.title?.bus.base64EncodedString)
        case let message as VideoMessage:
            XCTAssertEqual(queryItem!.value!, message.title?.bus.base64EncodedString)
        case let message as WebPageMessage:
            XCTAssertEqual(queryItem!.value!, message.title?.bus.base64EncodedString)
        case let message as FileMessage:
            XCTAssertEqual(queryItem!.value!, message.title?.bus.base64EncodedString)
        case let message as MiniProgramMessage:
            XCTAssertEqual(queryItem!.value!, message.title?.bus.base64EncodedString)
        default:
            XCTAssertTrue(false, String(describing: queryItem?.value))
        }
    }
}

// MARK: - Share - Message - UniversalLink

extension QQHandlerBaseTests: ShareMessageUniversalLinkTestCase {

    func test_share_message_ul(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint) {
        let cflag = queryItems.removeFirst { $0.name == "cflag" }!
        test_cflag(cflag, message, endpoint)

        let fileName = queryItems.removeFirst { $0.name == "fileName" }
        test_fileName(fileName, message)

        let file_data = queryItems.removeFirst { $0.name == "file_data" }
        test_file_data(file_data, message)

        let file_type = queryItems.removeFirst { $0.name == "file_type" }!
        test_file_type(file_type, message)

        let flashurl = queryItems.removeFirst { $0.name == "flashurl" }
        test_flashurl(flashurl, message)

        let generalpastboard = queryItems.removeFirst { $0.name == "generalpastboard" }
        test_generalpastboard(generalpastboard)

        let mini_appid = queryItems.removeFirst { $0.name == "mini_appid" }
        test_mini_appid(mini_appid, message)

        let mini_code64 = queryItems.removeFirst { $0.name == "mini_code64" }
        test_mini_code64(mini_code64, message)

        let mini_path = queryItems.removeFirst { $0.name == "mini_path" }
        test_mini_path(mini_path, message)

        let mini_type = queryItems.removeFirst { $0.name == "mini_type" }
        test_mini_type(mini_type, message)

        let mini_weburl = queryItems.removeFirst { $0.name == "mini_weburl" }
        test_mini_weburl(mini_weburl, message)

        let objectlocation = queryItems.removeFirst { $0.name == "objectlocation" }
        test_objectlocation(objectlocation, message)

        let pasteboard = queryItems.removeFirst { $0.name == "pasteboard" }
        test_pasteboard(pasteboard, message)

        let shareType = queryItems.removeFirst { $0.name == "shareType" }!
        test_shareType(shareType, message, endpoint)

        let url = queryItems.removeFirst { $0.name == "url" }
        test_url(url, message)
    }
}

extension QQHandlerBaseTests {

    func test_cflag(_ queryItem: URLQueryItem, _ message: MessageType, _ endpoint: Endpoint) {
        switch endpoint {
        case Endpoints.QQ.friend:
            switch message.identifier {
            case Messages.text,
                 Messages.image,
                 Messages.audio,
                 Messages.video,
                 Messages.webPage:
                XCTAssertEqual(queryItem.value!, "2")
            case Messages.file:
                XCTAssertEqual(queryItem.value!, "18")
            case Messages.miniProgram:
                XCTAssertEqual(queryItem.value!, "64")
            default:
                XCTAssertTrue(false, String(describing: queryItem.value))
            }
        case Endpoints.QQ.timeline:
            XCTAssertEqual(queryItem.value!, "0")
        default:
            XCTAssertTrue(false, String(describing: queryItem.value))
        }
    }

    func test_fileName(_ queryItem: URLQueryItem?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is MiniProgramMessage:
            XCTAssertNil(queryItem)
        case let message as FileMessage:
            XCTAssertEqual(queryItem!.value!, message.fullName)
        default:
            XCTAssertTrue(false, String(describing: queryItem?.value))
        }
    }

    func test_file_data(_ queryItem: URLQueryItem?, _ message: MessageType) {
        switch message {
        case let message as TextMessage:
            XCTAssertEqual(queryItem!.value!, message.text.bus.base64EncodedString)
        case is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage,
             is MiniProgramMessage:
            XCTAssertNil(queryItem)
        default:
            XCTAssertTrue(false, String(describing: queryItem?.value))
        }
    }

    func test_file_type(_ queryItem: URLQueryItem, _ message: MessageType) {
        switch message.identifier {
        case Messages.text:
            XCTAssertEqual(queryItem.value!, "text")
        case Messages.image:
            XCTAssertEqual(queryItem.value!, "img")
        case Messages.audio:
            XCTAssertEqual(queryItem.value!, "audio")
        case Messages.video:
            XCTAssertEqual(queryItem.value!, "video")
        case Messages.webPage:
            XCTAssertEqual(queryItem.value!, "news")
        case Messages.file:
            XCTAssertEqual(queryItem.value!, "localFile")
        case Messages.miniProgram:
            XCTAssertEqual(queryItem.value!, "news")
        default:
            XCTAssertTrue(false, String(describing: queryItem.value))
        }
    }

    func test_flashurl(_ queryItem: URLQueryItem?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage,
             is MiniProgramMessage:
            XCTAssertNil(queryItem)
        case let message as AudioMessage:
            XCTAssertEqual(queryItem!.value!, message.dataLink?.absoluteString.bus.base64EncodedString)
        default:
            XCTAssertTrue(false, String(describing: queryItem?.value))
        }
    }

    func test_generalpastboard(_ queryItem: URLQueryItem?) {
        XCTAssertEqual(queryItem!.value!, "1")
    }

    func test_mini_appid(_ queryItem: URLQueryItem?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage:
            XCTAssertNil(queryItem)
        case let message as MiniProgramMessage:
            XCTAssertEqual(queryItem!.value!, message.miniProgramID)
        default:
            XCTAssertTrue(false, String(describing: queryItem?.value))
        }
    }

    func test_mini_code64(_ queryItem: URLQueryItem?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage:
            XCTAssertNil(queryItem)
        case is MiniProgramMessage:
            XCTAssertEqual(queryItem!.value!, "1")
        default:
            XCTAssertTrue(false, String(describing: queryItem?.value))
        }
    }

    func test_mini_path(_ queryItem: URLQueryItem?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage:
            XCTAssertNil(queryItem)
        case let message as MiniProgramMessage:
            XCTAssertEqual(queryItem!.value!, message.path.bus.base64EncodedString)
        default:
            XCTAssertTrue(false, String(describing: queryItem?.value))
        }
    }

    func test_mini_type(_ queryItem: URLQueryItem?, _ message: MessageType) {
        let miniProgramType: (MiniProgramMessage.MiniProgramType) -> String = { miniProgramType in
            switch miniProgramType {
            case .release:
                return "3"
            case .test:
                return "1"
            case .preview:
                return "4"
            }
        }

        switch message {
        case is TextMessage,
             is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage:
            XCTAssertNil(queryItem)
        case let message as MiniProgramMessage:
            XCTAssertEqual(queryItem!.value!, miniProgramType(message.miniProgramType))
        default:
            XCTAssertTrue(false, String(describing: queryItem?.value))
        }
    }

    func test_mini_weburl(_ queryItem: URLQueryItem?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage:
            XCTAssertNil(queryItem)
        case let message as MiniProgramMessage:
            XCTAssertEqual(queryItem!.value!, message.link.absoluteString.bus.base64EncodedString)
        default:
            XCTAssertTrue(false, String(describing: queryItem?.value))
        }
    }

    func test_objectlocation(_ queryItem: URLQueryItem?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(queryItem)
        case is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is FileMessage:
            XCTAssertEqual(queryItem!.value!, "pasteboard")
        case is WebPageMessage,
             is MiniProgramMessage:
            XCTAssertEqual(queryItem!.value!, "url")
        default:
            XCTAssertTrue(false, String(describing: queryItem?.value))
        }
    }

    func test_pasteboard(_ queryItem: URLQueryItem?, _ message: MessageType) {
        let thumbnail: (String) -> Data = { value in
            let data = Data(base64Encoded: value)!
            let object = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: Any]
            return object["previewimagedata"] as! Data
        }

        switch message {
        case is TextMessage,
             is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is FileMessage:
            XCTAssertNil(queryItem)
        case let message as WebPageMessage:
            XCTAssertEqual(thumbnail(queryItem!.value!), message.thumbnail)
        case let message as MiniProgramMessage:
            XCTAssertEqual(thumbnail(queryItem!.value!), message.thumbnail)
        default:
            XCTAssertTrue(false, String(describing: queryItem?.value))
        }
    }

    func test_shareType(_ queryItem: URLQueryItem, _ message: MessageType, _ endpoint: Endpoint) {
        switch endpoint {
        case Endpoints.QQ.friend:
            switch message.identifier {
            case Messages.text,
                 Messages.image,
                 Messages.audio,
                 Messages.video,
                 Messages.webPage,
                 Messages.file,
                 Messages.miniProgram:
                XCTAssertEqual(queryItem.value!, "0")
            default:
                XCTAssertTrue(false, String(describing: queryItem.value))
            }
        case Endpoints.QQ.timeline:
            switch message.identifier {
            case Messages.text,
                 Messages.image:
                XCTAssertEqual(queryItem.value!, "0")
            case Messages.audio,
                 Messages.video,
                 Messages.webPage:
                XCTAssertEqual(queryItem.value!, "1")
            default:
                XCTAssertTrue(false, String(describing: queryItem.value))
            }
        default:
            XCTAssertTrue(false, String(describing: queryItem.value))
        }
    }

    func test_url(_ queryItem: URLQueryItem?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is FileMessage:
            XCTAssertNil(queryItem)
        case let message as AudioMessage:
            XCTAssertEqual(queryItem!.value!, message.link.absoluteString.bus.base64EncodedString)
        case let message as VideoMessage:
            XCTAssertEqual(queryItem!.value!, message.link.absoluteString.bus.base64EncodedString)
        case let message as WebPageMessage:
            XCTAssertEqual(queryItem!.value!, message.link.absoluteString.bus.base64EncodedString)
        case let message as MiniProgramMessage:
            XCTAssertEqual(queryItem!.value!, message.link.absoluteString.bus.base64EncodedString)
        default:
            XCTAssertTrue(false, String(describing: queryItem?.value))
        }
    }
}

// MARK: - Share - Common - Pasteboard

extension QQHandlerBaseTests: ShareCommonPasteboardTestCase {

    func test_share_common_pb(dictionary: inout [String: Any]) {
        XCTAssertTrue(true)
    }
}

// MARK: - Share - MediaMessage - Pasteboard

extension QQHandlerBaseTests: ShareMediaMessagePasteboardTestCase {

    func test_share_media_pb(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        let previewimagedata = dictionary.removeValue(forKey: "previewimagedata") as? Data
        test_previewimagedata(previewimagedata, message)
    }
}

extension QQHandlerBaseTests {

    func test_previewimagedata(_ value: Data?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(value)
        case let message as ImageMessage:
            XCTAssertEqual(value!, message.thumbnail)
        case let message as AudioMessage:
            XCTAssertEqual(value!, message.thumbnail)
        case let message as VideoMessage:
            XCTAssertEqual(value!, message.thumbnail)
        case let message as FileMessage:
            XCTAssertEqual(value!, message.thumbnail)
        default:
            XCTAssertTrue(false, String(describing: value))
        }
    }
}

// MARK: - Share - Message - Pasteboard

extension QQHandlerBaseTests: ShareMessagePasteboardTestCase {

    func test_share_message_pb(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        let file_data = dictionary.removeValue(forKey: "file_data") as? Data
        test_file_data(file_data, message)
    }
}

extension QQHandlerBaseTests {

    func test_file_data(_ value: Data?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is AudioMessage,
             is VideoMessage:
            XCTAssertNil(value)
        case let message as ImageMessage:
            XCTAssertEqual(value!, message.data)
        case let message as FileMessage:
            XCTAssertEqual(value!, message.data)
        default:
            XCTAssertTrue(false, String(describing: value))
        }
    }
}
