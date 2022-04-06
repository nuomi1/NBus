//
//  WeiboHandlerBaseTests.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/4.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import NBusWeiboSDK
import RxSwift
import XCTest

class WeiboHandlerBaseTests: HandlerBaseTests {

    override var appID: String {
        switch handler {
        case let handler as WeiboSDKHandler:
            return handler.appID
        case let handler as WeiboHandler:
            return handler.appID
        default:
            fatalError()
        }
    }

    var redirectLink: URL {
        switch handler {
        case let handler as WeiboSDKHandler:
            return handler.redirectLink
        case let handler as WeiboHandler:
            return handler.redirectLink
        default:
            fatalError()
        }
    }

    override var sdkShortVersion: String {
        "3.3"
    }

    override var sdkVersion: String {
        "003233000"
    }

    override var universalLink: URL {
        switch handler {
        case let handler as WeiboSDKHandler:
            return handler.universalLink
        case let handler as WeiboHandler:
            return handler.universalLink
        default:
            fatalError()
        }
    }

    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
        return dateFormatter
    }()
}

// MARK: - General - UniversalLink

extension WeiboHandlerBaseTests: GeneralUniversalLinkTestCase {

    func test_general_ul(scheme: String) {
        XCTAssertEqual(scheme, "https")
    }

    func test_general_ul(host: String) {
        XCTAssertEqual(host, "open.weibo.com")
    }

    func test_general_ul(queryItems: inout [URLQueryItem]) {
        let lfid = queryItems.removeFirst { $0.name == "lfid" }!
        test_lfid(lfid)

        let luicode = queryItems.removeFirst { $0.name == "luicode" }!
        test_luicode(luicode)

        let newVersion = queryItems.removeFirst { $0.name == "newVersion" }!
        test_newVersion(newVersion)

        let objId = queryItems.removeFirst { $0.name == "objId" }!
        test_objId(objId)

        let sdkversion = queryItems.removeFirst { $0.name == "sdkversion" }!
        test_sdkversion(sdkversion)

        let urltype = queryItems.removeFirst { $0.name == "urltype" }!
        test_urltype(urltype)
    }
}

extension WeiboHandlerBaseTests {

    func test_lfid(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, bundleID)
    }

    func test_luicode(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, "10000360")
    }

    func test_newVersion(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, sdkShortVersion)
    }

    func test_objId(_ queryItem: URLQueryItem) {
        XCTAssertNotNil(UUID(uuidString: queryItem.value!))
    }

    func test_sdkversion(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, sdkVersion)
    }

    func test_urltype(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, "link")
    }
}

// MARK: - General - Pasteboard

extension WeiboHandlerBaseTests: GeneralPasteboardTestCase {

    func test_extract_major_pb(items: inout [[String: Data]]) -> [String: Any] {
        test_extract_KeyedArchiver_pb(items: &items, key: "transferObject")
    }

    func test_general_pb(dictionary: inout [String: Any]) {
        let requestID = dictionary.removeValue(forKey: "requestID") as! String
        test_requestID(requestID)
    }

    func test_extra_pb(items: inout [[String: Data]]) {
        test_app(&items)

        test_sdkVersion(&items)

        test_userInfo(&items)
    }
}

extension WeiboHandlerBaseTests {

    func test_requestID(_ value: String) {
        XCTAssertNotNil(UUID(uuidString: value))
    }
}

extension WeiboHandlerBaseTests {

    func test_app(_ items: inout [[String: Data]]) {
        var dictionary = test_extract_KeyedArchiver_pb(items: &items, key: "app")

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        let aid = dictionary.removeValue(forKey: "aid") as! String
        test_aid(aid)

        let appKey = dictionary.removeValue(forKey: "appKey") as! String
        test_appKey(appKey)

        let bundleID = dictionary.removeValue(forKey: "bundleID") as! String
        test_bundleID(bundleID)

        let universalLink = dictionary.removeValue(forKey: "universalLink") as! String
        test_universalLink(universalLink)

        logger.debug("\(UIPasteboard.self), end, \(dictionary.keys.sorted())")

        XCTAssertTrue(dictionary.isEmpty)
    }
}

extension WeiboHandlerBaseTests {

    func test_aid(_ value: String) {
        XCTAssertEqual(value.count, 50)
    }

    func test_appKey(_ value: String) {
        XCTAssertEqual(value, appNumber)
    }

    func test_bundleID(_ value: String) {
        XCTAssertEqual(value, bundleID)
    }

    func test_universalLink(_ value: String) {
        XCTAssertEqual(value, universalLink.absoluteString)
    }
}

extension WeiboHandlerBaseTests {

    func test_sdkVersion(_ items: inout [[String: Data]]) {
        let data = items.removeFirst { $0.keys.contains("sdkVersion") }!["sdkVersion"]!

        XCTAssertEqual(data, Data(sdkVersion.utf8))
    }
}

extension WeiboHandlerBaseTests {

    func test_userInfo(_ items: inout [[String: Data]]) {
        var dictionary = test_extract_KeyedArchiver_pb(items: &items, key: "userInfo")

        logger.debug("\(UIPasteboard.self), start, \(dictionary.keys.sorted())")

        let startTime = dictionary.removeValue(forKey: "startTime") as! String
        test_startTime(startTime)

        logger.debug("\(UIPasteboard.self), end, \(dictionary.keys.sorted())")

        XCTAssertTrue(dictionary.isEmpty)
    }
}

extension WeiboHandlerBaseTests {

    func test_startTime(_ value: String) {
        XCTAssertNotNil(dateFormatter.date(from: value))
    }
}

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

// MARK: - Share - Common - UniversalLink

extension WeiboHandlerBaseTests: ShareCommonUniversalLinkTestCase {

    func test_share_common_ul(path: String) {
        XCTAssertEqual(path, "/weibosdk/request")
    }

    func test_share_common_ul(queryItems: inout [URLQueryItem]) {
        XCTAssertTrue(true)
    }
}

// MARK: - Share - MediaMessage - UniversalLink

extension WeiboHandlerBaseTests: ShareMediaMessageUniversalLinkTestCase {

    func test_share_media_ul(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint) {
        XCTAssertTrue(true)
    }
}

// MARK: - Share - Message - UniversalLink

extension WeiboHandlerBaseTests: ShareMessageUniversalLinkTestCase {

    func test_share_message_ul(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint) {
        XCTAssertTrue(true)
    }
}

// MARK: - Share - Common - Pasteboard

extension WeiboHandlerBaseTests: ShareCommonPasteboardTestCase {

    func test_share_common_pb(dictionary: inout [String: Any]) {
        let `class` = dictionary.removeValue(forKey: "__class") as! String
        test_class_share(`class`)
    }
}

extension WeiboHandlerBaseTests {

    func test_class_share(_ value: String) {
        XCTAssertEqual(value, "WBSendMessageToWeiboRequest")
    }
}

// MARK: - Share - MediaMessage - Pasteboard

extension WeiboHandlerBaseTests: ShareMediaMessagePasteboardTestCase {

    func test_share_media_pb(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        XCTAssertTrue(true)
    }
}

// MARK: - Share - Message - Pasteboard

extension WeiboHandlerBaseTests: ShareMessagePasteboardTestCase {

    func test_share_message_pb(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        let _message = dictionary.removeValue(forKey: "message") as! [String: Any]
        test_message(_message, message, endpoint)
    }
}

extension WeiboHandlerBaseTests {

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
            test_image(value!, message, endpoint)
        default:
            XCTAssertTrue(false, String(describing: value))
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
            test_media(value!, message, endpoint)
        default:
            XCTAssertTrue(false, String(describing: value))
        }
    }

    func test_text(_ value: String?, _ message: MessageType) {
        switch message {
        case let message as TextMessage:
            XCTAssertEqual(value!, message.text)
        case is ImageMessage,
             is AudioMessage,
             is VideoMessage,
             is WebPageMessage:
            XCTAssertNil(value)
        default:
            XCTAssertTrue(false, String(describing: value))
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
            XCTAssertTrue(false, String(describing: value))
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
            XCTAssertTrue(false, String(describing: value))
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
            XCTAssertTrue(false, String(describing: value))
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
            XCTAssertTrue(false, String(describing: value))
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
            XCTAssertTrue(false, String(describing: value))
        }
    }
}

// MARK: - Share - Completion

extension WeiboHandlerBaseTests: ShareCompletionTestCase {

    func test_share_avoid_error(_ error: Bus.Error, _ message: MessageType, _ endpoint: Endpoint) -> Bool {
        (message.identifier == Messages.file && endpoint == Endpoints.Weibo.timeline)
            || (message.identifier == Messages.miniProgram && endpoint == Endpoints.Weibo.timeline)
    }
}

// MARK: - Oauth

extension WeiboHandlerBaseTests: OauthTestCase {

    func test_oauth() {
        test_oauth(Platforms.weibo)
    }
}

// MARK: - Oauth - Platform -UniversalLink

extension WeiboHandlerBaseTests: OauthPlatformUniversalLinkTestCase {

    func test_oauth_ul(path: String) {
        test_share_common_ul(path: path)
    }

    func test_oauth_ul(queryItems: inout [URLQueryItem], _ platform: Platform) {
        XCTAssertTrue(true)
    }
}

// MARK: - Oauth - Platform - Pasteboard

extension WeiboHandlerBaseTests: OauthPlatformPasteboardTestCase {

    func test_oauth_pb(dictionary: inout [String: Any], _ platform: Platform) {
        let `class` = dictionary.removeValue(forKey: "__class") as! String
        test_class_oauth(`class`)

        let redirectURI = dictionary.removeValue(forKey: "redirectURI") as! String
        test_redirectURI(redirectURI)
    }
}

extension WeiboHandlerBaseTests {

    func test_class_oauth(_ value: String) {
        XCTAssertEqual(value, "WBAuthorizeRequest")
    }

    func test_redirectURI(_ value: String) {
        XCTAssertEqual(value, redirectLink.absoluteString)
    }
}
