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
            fatalError()
        }
    }
}

// MARK: - Share - Message - UniversalLink - Request

extension QQHandlerBaseTests: ShareMessageUniversalLinkRequestTestCase {

    func test_share_ul_request(path: String) {
        XCTAssertEqual(path, "/opensdkul/mqqapi/share/to_fri")
    }

    func test_share_ul_request(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint) {
        let appsign_token = queryItems.removeFirst(where: { $0.name == "appsign_token" })
        test_appsign_token_share(appsign_token)

        let appsign_txid = queryItems.removeFirst(where: { $0.name == "appsign_txid" })
        test_appsign_txid_share(appsign_txid)

        let callback_name = queryItems.removeFirst { $0.name == "callback_name" }!
        test_callback_name(callback_name)

        let callback_type = queryItems.removeFirst { $0.name == "callback_type" }!
        test_callback_type(callback_type)

        let cflag = queryItems.removeFirst { $0.name == "cflag" }!
        test_cflag(cflag, message, endpoint)

        let description = queryItems.removeFirst { $0.name == "description" }
        test_description(description, message)

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

        let openredirect = queryItems.removeFirst(where: { $0.name == "openredirect" })
        test_openredirect(openredirect)

        let pasteboard = queryItems.removeFirst { $0.name == "pasteboard" }
        test_pasteboard(pasteboard, message)

        let shareType = queryItems.removeFirst { $0.name == "shareType" }!
        test_shareType(shareType, message, endpoint)

        let src_type = queryItems.removeFirst { $0.name == "src_type" }!
        test_src_type(src_type)

        let thirdAppDisplayName = queryItems.removeFirst { $0.name == "thirdAppDisplayName" }!
        test_thirdAppDisplayName(thirdAppDisplayName)

        let title = queryItems.removeFirst { $0.name == "title" }
        test_title(title, message)

        let url = queryItems.removeFirst { $0.name == "url" }
        test_url(url, message)

        let version = queryItems.removeFirst { $0.name == "version" }!
        test_version(version)
    }
}

extension QQHandlerBaseTests {

    func test_appsign_token_share(_ queryItem: URLQueryItem?) {
        switch context.shareState! {
        case .requestFirst:
            XCTAssertNil(queryItem)
        case .signToken,
             .requestSecond:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value).count, 32)
        case .requestThird,
             .responseURLScheme,
             .responseUniversalLink,
             .success,
             .failure:
            fatalError()
        }
    }

    func test_appsign_txid_share(_ queryItem: URLQueryItem?) {
        switch context.shareState! {
        case .requestFirst:
            XCTAssertNil(queryItem)
        case .signToken,
             .requestSecond:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), txID)
        case .requestThird,
             .responseURLScheme,
             .responseUniversalLink,
             .success,
             .failure:
            fatalError()
        }
    }

    func test_callback_name(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), txID)
    }

    func test_callback_type(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), "scheme")
    }

    func test_cflag(_ queryItem: URLQueryItem, _ message: MessageType, _ endpoint: Endpoint) {
        switch endpoint {
        case Endpoints.QQ.friend:
            switch message.identifier {
            case Messages.text,
                 Messages.image,
                 Messages.audio,
                 Messages.video,
                 Messages.webPage:
                XCTAssertEqual(try XCTUnwrap(queryItem.value), "2")
            case Messages.file:
                XCTAssertEqual(try XCTUnwrap(queryItem.value), "18")
            case Messages.miniProgram:
                XCTAssertEqual(try XCTUnwrap(queryItem.value), "64")
            default:
                fatalError()
            }
        case Endpoints.QQ.timeline:
            XCTAssertEqual(try XCTUnwrap(queryItem.value), "0")
        default:
            fatalError()
        }
    }

    func test_description(_ queryItem: URLQueryItem?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(queryItem)
        case let message as ImageMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.description?.bus.base64EncodedString)
        case let message as AudioMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.description?.bus.base64EncodedString)
        case let message as VideoMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.description?.bus.base64EncodedString)
        case let message as WebPageMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.description?.bus.base64EncodedString)
        case let message as FileMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.description?.bus.base64EncodedString)
        case let message as MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.description?.bus.base64EncodedString)
        default:
            fatalError()
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
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.fullName)
        default:
            fatalError()
        }
    }

    func test_file_data(_ queryItem: URLQueryItem?, _ message: MessageType) {
        switch message {
        case let message as TextMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.text.bus.base64EncodedString)
        case is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage,
             is FileMessage,
             is MiniProgramMessage:
            XCTAssertNil(queryItem)
        default:
            fatalError()
        }
    }

    func test_file_type(_ queryItem: URLQueryItem, _ message: MessageType) {
        switch message.identifier {
        case Messages.text:
            XCTAssertEqual(try XCTUnwrap(queryItem.value), "text")
        case Messages.image:
            XCTAssertEqual(try XCTUnwrap(queryItem.value), "img")
        case Messages.audio:
            XCTAssertEqual(try XCTUnwrap(queryItem.value), "audio")
        case Messages.video:
            XCTAssertEqual(try XCTUnwrap(queryItem.value), "video")
        case Messages.webPage:
            XCTAssertEqual(try XCTUnwrap(queryItem.value), "news")
        case Messages.file:
            XCTAssertEqual(try XCTUnwrap(queryItem.value), "localFile")
        case Messages.miniProgram:
            XCTAssertEqual(try XCTUnwrap(queryItem.value), "news")
        default:
            fatalError()
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
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.dataLink?.absoluteString.bus.base64EncodedString)
        default:
            fatalError()
        }
    }

    func test_generalpastboard(_ queryItem: URLQueryItem?) {
        XCTAssertEqual(try XCTUnwrap(queryItem?.value), "1")
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
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.miniProgramID)
        default:
            fatalError()
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
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), "1")
        default:
            fatalError()
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
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.path.bus.base64EncodedString)
        default:
            fatalError()
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
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), miniProgramType(message.miniProgramType))
        default:
            fatalError()
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
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.link.absoluteString.bus.base64EncodedString)
        default:
            fatalError()
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
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), "pasteboard")
        case is WebPageMessage,
             is MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), "url")
        default:
            fatalError()
        }
    }

    func test_openredirect(_ queryItem: URLQueryItem?) {
        switch context.shareState! {
        case .requestFirst:
            XCTAssertNil(queryItem)
        case .signToken,
             .requestSecond:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), "1")
        case .requestThird,
             .responseURLScheme,
             .responseUniversalLink,
             .success,
             .failure:
            fatalError()
        }
    }

    func test_pasteboard(_ queryItem: URLQueryItem?, _ message: MessageType) {
        let thumbnail: (String) throws -> Data = { value in
            let data = try XCTUnwrap(Data(base64Encoded: value))
            var object = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: Any]
            let thumbnail = object.removeValue(forKey: "previewimagedata") as! Data
            XCTAssertTrue(object.isEmpty)
            return thumbnail
        }

        switch message {
        case is TextMessage,
             is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is FileMessage:
            XCTAssertNil(queryItem)
        case let message as WebPageMessage:
            XCTAssertEqual(try thumbnail(XCTUnwrap(queryItem?.value)), message.thumbnail)
        case let message as MiniProgramMessage:
            XCTAssertEqual(try thumbnail(XCTUnwrap(queryItem?.value)), message.thumbnail)
        default:
            fatalError()
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
                XCTAssertEqual(try XCTUnwrap(queryItem.value), "0")
            default:
                fatalError()
            }
        case Endpoints.QQ.timeline:
            switch message.identifier {
            case Messages.text,
                 Messages.image:
                XCTAssertEqual(try XCTUnwrap(queryItem.value), "0")
            case Messages.audio,
                 Messages.video,
                 Messages.webPage:
                XCTAssertEqual(try XCTUnwrap(queryItem.value), "1")
            default:
                fatalError()
            }
        default:
            fatalError()
        }
    }

    func test_src_type(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), "app")
    }

    func test_thirdAppDisplayName(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), displayName.bus.base64EncodedString)
    }

    func test_title(_ queryItem: URLQueryItem?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(queryItem)
        case let message as ImageMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.title?.bus.base64EncodedString)
        case let message as AudioMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.title?.bus.base64EncodedString)
        case let message as VideoMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.title?.bus.base64EncodedString)
        case let message as WebPageMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.title?.bus.base64EncodedString)
        case let message as FileMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.title?.bus.base64EncodedString)
        case let message as MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.title?.bus.base64EncodedString)
        default:
            fatalError()
        }
    }

    func test_url(_ queryItem: URLQueryItem?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is FileMessage:
            XCTAssertNil(queryItem)
        case let message as AudioMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.link.absoluteString.bus.base64EncodedString)
        case let message as VideoMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.link.absoluteString.bus.base64EncodedString)
        case let message as WebPageMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.link.absoluteString.bus.base64EncodedString)
        case let message as MiniProgramMessage:
            XCTAssertEqual(try XCTUnwrap(queryItem?.value), message.link.absoluteString.bus.base64EncodedString)
        default:
            fatalError()
        }
    }

    func test_version(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), "1")
    }
}

// MARK: - Share - Message - Pasteboard - Request

extension QQHandlerBaseTests: ShareMessagePasteboardRequestTestCase {

    func test_share_pb_request(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        let file_data = dictionary.removeValue(forKey: "file_data") as? Data
        test_file_data(file_data, message)

        let previewimagedata = dictionary.removeValue(forKey: "previewimagedata") as? Data
        test_previewimagedata(previewimagedata, message)
    }
}

extension QQHandlerBaseTests {

    func test_file_data(_ value: Data?, _ message: MessageType) {
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

    func test_previewimagedata(_ value: Data?, _ message: MessageType) {
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
}

// MARK: - Share - Message - URLScheme - Response

extension QQHandlerBaseTests: ShareMessageURLSchemeResponseTestCase {

    func test_share_us_response(path: String) {
        XCTAssertEqual(path, "")
    }

    func test_share_us_response(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint) {
        if context.shareState == .responseURLScheme {
            let appsign_token = queryItems.removeFirst { $0.name == "appsign_token" }!
            test_appsign_token_share(appsign_token)
        }

        let error = queryItems.removeFirst { $0.name == "error" }!
        let error_description = queryItems.removeFirst { $0.name == "error_description" }

        switch try! XCTUnwrap(error.value) {
        case "0":
            context.shareState = .success

            XCTAssertNil(error_description)
        case "--1000710008":
            context.shareState = .failure

            XCTAssertEqual(try XCTUnwrap(error_description?.value), "主体信息不一致，无法打开".bus.base64EncodedString)
        default:
            fatalError()
        }
    }
}

// MARK: - Share - Message - UniversalLink - Response

extension QQHandlerBaseTests: ShareMessageUniversalLinkResponseTestCase {

    func test_share_ul_response(path: String) {
        let isSignToken = path == universalLink.appendingPathComponent("\(bundleID)/mqqsignapp").path
        let isResponse = path == universalLink.appendingPathComponent("\(bundleID)").path

        if isSignToken {
            context.shareState = .signToken
        } else if isResponse {
            context.shareState = .responseUniversalLink
        }

        XCTAssertTrue(isSignToken || isResponse)
    }

    func test_share_ul_response(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint) {
        switch context.shareState! {
        case .requestFirst,
             .requestSecond,
             .requestThird,
             .responseURLScheme,
             .success,
             .failure:
            fatalError()
        case .signToken:
            let generalpastboard = queryItems.removeFirst { $0.name == "generalpastboard" }!
            test_generalpastboard(generalpastboard)
        case .responseUniversalLink:
            let sdkactioninfo = extract_JSON_ul(queryItems: &queryItems, key: "sdkactioninfo")
            test_sdkactioninfo_share(sdkactioninfo, message, endpoint)
        }
    }
}

extension QQHandlerBaseTests {

    func test_sdkactioninfo_us(_ value: [String: Any]) -> URL {
        var dictionary = value as! [String: String]

        var urlComponents = URLComponents()

        urlComponents.scheme = dictionary.removeValue(forKey: "sdk_action_sheme")!
        urlComponents.host = dictionary.removeValue(forKey: "sdk_action_host")!
        urlComponents.path = dictionary.removeValue(forKey: "sdk_action_path")!
        urlComponents.query = dictionary.removeValue(forKey: "sdk_action_query")!

        XCTAssertTrue(dictionary.isEmpty)

        return urlComponents.url!
    }

    func test_sdkactioninfo_share(_ value: [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        _test_share_response(us: test_sdkactioninfo_us(value), message, endpoint)
    }
}

// MARK: - Share - Message - Pasteboard - Response

extension QQHandlerBaseTests: ShareMessagePasteboardResponseTestCase {

    func test_share_pb_response(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        let appsign_redirect_pasteboard = dictionary.removeValue(forKey: "appsign_redirect_pasteboard") as! [String: Any]
        test_appsign_redirect_pasteboard(appsign_redirect_pasteboard, message, endpoint)
    }
}

extension QQHandlerBaseTests {

    func test_appsign_redirect_pasteboard(_ value: [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        var dictionary = value

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        let file_data = dictionary.removeValue(forKey: "file_data") as? Data
        test_file_data(file_data, message)

        if !context.skipPasteboard, context.setPasteboardString {
            let pasted_string = dictionary.removeValue(forKey: "pasted_string") as! String
            test_pasted_string(pasted_string)
        }

        let previewimagedata = dictionary.removeValue(forKey: "previewimagedata") as? Data
        test_previewimagedata(previewimagedata, message)

        logger.debug("\(UIPasteboard.self), end, \(dictionary.keys.sorted())")

        XCTAssertTrue(dictionary.isEmpty)
    }
}
