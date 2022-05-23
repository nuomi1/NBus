//
//  WeiboHandlerBaseTests+Share.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import XCTest

// MARK: - Share

extension WeiboHandlerBaseTests: ShareTestCase {

    func test_share_text_timeline() {
        test_share(MediaSource.text, Endpoints.Weibo.timeline)
    }

    func test_share_image_timeline() {
        test_share(MediaSource.image, Endpoints.Weibo.timeline)
    }

    func test_share_audio_timeline() {
        test_share(MediaSource.audio, Endpoints.Weibo.timeline)
    }

    func test_share_video_timeline() {
        test_share(MediaSource.video, Endpoints.Weibo.timeline)
    }

    func test_share_webPage_timeline() {
        test_share(MediaSource.webPage, Endpoints.Weibo.timeline)
    }

    func test_share_file_timeline() {
        test_share(MediaSource.file, Endpoints.Weibo.timeline)
    }

    func test_share_miniProgram_timeline() {
        test_share(MediaSource.wechatMiniProgram, Endpoints.Weibo.timeline)
    }
}

// MARK: - Share - Message - Scheme

extension WeiboHandlerBaseTests: ShareMessageSchemeTestCase {

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

extension WeiboHandlerBaseTests: ShareMessageUniversalLinkRequestTestCase {

    func test_share_ul_request(path: String) {
        XCTAssertEqual(path, "/weibosdk/request")
    }

    func test_share_ul_request(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint) {
        if context.shareState == .requestFirst {
            let checkLink = queryItems.removeFirst { $0.name == "checkLink" }!
            test_checkLink_request(checkLink)
        }

        if context.shareState == .requestSecond {
            let lfid = queryItems.removeFirst { $0.name == "lfid" }!
            test_lfid(lfid)
        }

        if context.shareState == .requestSecond {
            let luicode = queryItems.removeFirst { $0.name == "luicode" }!
            test_luicode(luicode)
        }

        if context.shareState == .requestSecond {
            let sdkversion = queryItems.removeFirst { $0.name == "sdkversion" }!
            test_sdkversion(sdkversion)
        }

        if context.shareState == .requestSecond {
            let urltype = queryItems.removeFirst { $0.name == "urltype" }!
            test_urltype(urltype)
        }
    }
}

extension WeiboHandlerBaseTests {

    func test_checkLink_request(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), universalLink.absoluteString)
    }

    func test_lfid(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), bundleID)
    }

    func test_luicode(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), "10000360")
    }

    func test_sdkversion(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), sdkVersion)
    }

    func test_urltype(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), "link")
    }
}

// MARK: - Share - Message - Pasteboard - Request

extension WeiboHandlerBaseTests: ShareMessagePasteboardRequestTestCase {

    func test_share_pb_request(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        if context.shareState == .requestSecond {
            let `class` = dictionary.removeValue(forKey: "__class") as! String
            test_class_share(`class`)
        }

        if context.shareState == .requestSecond {
            let _message = dictionary.removeValue(forKey: "message") as! [String: Any]
            test_message(_message, message, endpoint)
        }
    }
}

extension WeiboHandlerBaseTests {

    func test_class_share(_ value: String) {
        XCTAssertEqual(value, "WBSendMessageToWeiboRequest")
    }

    func test_message(_ value: [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        var dictionary = value

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        let `class` = dictionary.removeValue(forKey: "__class") as! String
        test_class_message(`class`)

        let imageObject = dictionary.removeValue(forKey: "imageObject") as? [String: Any]
        test_imageObject(imageObject, message, endpoint)

        let mediaObject = dictionary.removeValue(forKey: "mediaObject") as? [String: Any]
        test_mediaObject(mediaObject, message, endpoint)

        let text = dictionary.removeValue(forKey: "text") as? String
        test_text(text, message)

        logger.debug("\(UIPasteboard.self), end, \(dictionary.keys.sorted())")

        XCTAssertTrue(dictionary.isEmpty)
    }
}

extension WeiboHandlerBaseTests {

    func test_class_message(_ value: String) {
        XCTAssertEqual(value, "WBMessageObject")
    }

    func test_imageObject(_ value: [String: Any]?, _ message: MessageType, _ endpoint: Endpoint) {
        switch message {
        case is TextMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage:
            XCTAssertNil(value)
        case is ImageMessage:
            test_image(try! XCTUnwrap(value), message, endpoint)
        default:
            fatalError()
        }
    }

    func test_mediaObject(_ value: [String: Any]?, _ message: MessageType, _ endpoint: Endpoint) {
        switch message {
        case is TextMessage,
             is ImageMessage:
            XCTAssertNil(value)
        case is AudioMessage,
             is VideoMessage,
             is WebPageMessage:
            test_media(try! XCTUnwrap(value), message, endpoint)
        default:
            fatalError()
        }
    }

    func test_text(_ value: String?, _ message: MessageType) {
        switch message {
        case let message as TextMessage:
            XCTAssertEqual(try XCTUnwrap(value), message.text)
        case is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage:
            XCTAssertNil(value)
        default:
            fatalError()
        }
    }
}

extension WeiboHandlerBaseTests {

    func test_image(_ value: [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        var dictionary = value

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        let imageData = dictionary.removeValue(forKey: "imageData") as! Data
        test_imageData(imageData, message)

        logger.debug("\(UIPasteboard.self), end, \(dictionary.keys.sorted())")

        XCTAssertTrue(dictionary.isEmpty)
    }
}

extension WeiboHandlerBaseTests {

    func test_imageData(_ value: Data, _ message: MessageType) {
        switch message {
        case let message as ImageMessage:
            XCTAssertEqual(value, message.data)
        default:
            fatalError()
        }
    }
}

extension WeiboHandlerBaseTests {

    func test_media(_ value: [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        var dictionary = value

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        let `class` = dictionary.removeValue(forKey: "__class") as! String
        test_class_media(`class`)

        let description = dictionary.removeValue(forKey: "description") as! String
        test_description(description, message)

        let objectID = dictionary.removeValue(forKey: "objectID") as! String
        test_objectID(objectID)

        let thumbnailData = dictionary.removeValue(forKey: "thumbnailData") as! Data
        test_thumbnailData(thumbnailData, message)

        let title = dictionary.removeValue(forKey: "title") as! String
        test_title(title, message)

        let webpageUrl = dictionary.removeValue(forKey: "webpageUrl") as! String
        test_webpageUrl(webpageUrl, message)

        logger.debug("\(UIPasteboard.self), end, \(dictionary.keys.sorted())")

        XCTAssertTrue(dictionary.isEmpty)
    }
}

extension WeiboHandlerBaseTests {

    func test_class_media(_ value: String) {
        XCTAssertEqual(value, "WBWebpageObject")
    }

    func test_description(_ value: String, _ message: MessageType) {
        switch message {
        case let message as AudioMessage:
            XCTAssertEqual(value, message.description)
        case let message as VideoMessage:
            XCTAssertEqual(value, message.description)
        case let message as WebPageMessage:
            XCTAssertEqual(value, message.description)
        default:
            fatalError()
        }
    }

    func test_objectID(_ value: String) {
        XCTAssertNotNil(UUID(uuidString: value))
    }

    func test_thumbnailData(_ value: Data, _ message: MessageType) {
        switch message {
        case let message as AudioMessage:
            XCTAssertEqual(value, message.thumbnail)
        case let message as VideoMessage:
            XCTAssertEqual(value, message.thumbnail)
        case let message as WebPageMessage:
            XCTAssertEqual(value, message.thumbnail)
        default:
            fatalError()
        }
    }

    func test_title(_ value: String, _ message: MessageType) {
        switch message {
        case let message as AudioMessage:
            XCTAssertEqual(value, message.title)
        case let message as VideoMessage:
            XCTAssertEqual(value, message.title)
        case let message as WebPageMessage:
            XCTAssertEqual(value, message.title)
        default:
            fatalError()
        }
    }

    func test_webpageUrl(_ value: String, _ message: MessageType) {
        switch message {
        case let message as AudioMessage:
            XCTAssertEqual(value, message.link.absoluteString)
        case let message as VideoMessage:
            XCTAssertEqual(value, message.link.absoluteString)
        case let message as WebPageMessage:
            XCTAssertEqual(value, message.link.absoluteString)
        default:
            fatalError()
        }
    }
}

// MARK: - Share - Message - URLScheme - Response

extension WeiboHandlerBaseTests: ShareMessageURLSchemeResponseTestCase {

    func test_share_us_response(path: String) {
        fatalError()
    }

    func test_share_us_response(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint) {
        fatalError()
    }
}

// MARK: - Share - Message - UniversalLink - Response

extension WeiboHandlerBaseTests: ShareMessageUniversalLinkResponseTestCase {

    func test_share_ul_response(path: String) {
        XCTAssertEqual(path, universalLink.appendingPathComponent("weibosdk/response").path)
    }

    func test_share_ul_response(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint) {
        if context.shareState == .responseSignToken {
            let checkLink = queryItems.removeFirst { $0.name == "checkLink" }!
            test_checkLink_response(checkLink)
        }

        if context.shareState == .responseSignToken {
            let checkStatus = queryItems.removeFirst { $0.name == "checkStatus" }!
            test_checkStatus(checkStatus)
        }

        if context.shareState == .responseUniversalLink {
            let sdkversion = queryItems.removeFirst { $0.name == "sdkversion" }!
            test_sdkversion_response(sdkversion)
        }
    }
}

extension WeiboHandlerBaseTests {

    func test_checkLink_response(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), "https://open.weibo.com/weibosdk")
    }

    func test_checkStatus(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), "1")
    }

    func test_sdkversion_response(_ queryItem: URLQueryItem) {
        XCTAssertEqual(try XCTUnwrap(queryItem.value), remoteSDKShortVersion)
    }
}

// MARK: - Share - Message - Pasteboard - Response

extension WeiboHandlerBaseTests: ShareMessagePasteboardResponseTestCase {

    func test_share_pb_response(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        if context.shareState == .responseUniversalLink {
            let `class` = dictionary.removeValue(forKey: "__class") as! String
            test_class_share_response(`class`)
        }

        if context.shareState == .responseUniversalLink {
            let requestID = dictionary.removeValue(forKey: "requestID") as! String
            test_requestID(requestID)
        }

        if context.shareState == .responseUniversalLink {
            let responseID = dictionary.removeValue(forKey: "responseID") as! String
            test_responseID(responseID)
        }

        if context.shareState == .responseUniversalLink {
            let statusCode = dictionary.removeValue(forKey: "statusCode") as! Int
            test_statusCode_share(statusCode)
        }
    }
}

extension WeiboHandlerBaseTests {

    func test_class_share_response(_ value: String) {
        XCTAssertEqual(value, "WBSendMessageToWeiboResponse")
    }

    func test_responseID(_ value: String) {
        XCTAssertNotNil(UUID(uuidString: value))
    }

    func test_statusCode_share(_ value: Int) {
        switch value {
        case 0:
            context.shareState = .success
        case -1:
            context.shareState = .failure
        default:
            fatalError()
        }
    }
}
