//
//  WechatHandlerBaseTests.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/1.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import RxSwift
import XCTest

class WechatHandlerBaseTests: HandlerBaseTests {

    override var appID: String {
        switch handler {
        case let handler as WechatSDKHandler:
            return handler.appID
        case let handler as WechatHandler:
            return handler.appID
        default:
            fatalError()
        }
    }

    override var sdkVersion: String {
        "1.9.2"
    }

    override var universalLink: URL {
        switch handler {
        case let handler as WechatSDKHandler:
            return handler.universalLink
        case let handler as WechatHandler:
            return handler.universalLink
        default:
            fatalError()
        }
    }
}

// MARK: - General - UniversalLink

extension WechatHandlerBaseTests: GeneralUniversalLinkTestCase {

    func test_general_ul(scheme: String) {
        XCTAssertEqual(scheme, "https")
    }

    func test_general_ul(host: String) {
        XCTAssertEqual(host, "help.wechat.com")
    }

    func test_general_ul(queryItems: inout [URLQueryItem]) {
        let wechat_app_bundleId = queryItems.removeFirst { $0.name == "wechat_app_bundleId" }!
        test_wechat_app_bundleId(wechat_app_bundleId)

        let wechat_auth_context_id = queryItems.removeFirst { $0.name == "wechat_auth_context_id" }!
        test_wechat_auth_context_id(wechat_auth_context_id)
    }
}

extension WechatHandlerBaseTests {

    func test_wechat_app_bundleId(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, bundleID)
    }

    func test_wechat_auth_context_id(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!.count, 64)
    }
}

// MARK: - General - Pasteboard

extension WechatHandlerBaseTests: GeneralPasteboardTestCase {

    func test_extract_major_pb(items: inout [[String: Data]]) -> [String: Any] {
        let plist = test_extract_PropertyList_pb(items: &items, key: "content")
        let dictionary = plist[appID] as! [String: Any]

        return dictionary
    }

    func test_general_pb(dictionary: inout [String: Any]) {
        let isAutoResend = dictionary.removeValue(forKey: "isAutoResend") as! Bool
        test_isAutoResend(isAutoResend)

        let result = dictionary.removeValue(forKey: "result") as! String
        test_result(result)

        let returnFromApp = dictionary.removeValue(forKey: "returnFromApp") as! String
        test_returnFromApp(returnFromApp)

        let sdkver = dictionary.removeValue(forKey: "sdkver") as! String
        test_sdkver(sdkver)

        let universalLink = dictionary.removeValue(forKey: "universalLink") as! String
        test_universalLink(universalLink)
    }

    func test_extra_pb(items: inout [[String: Data]]) {
        XCTAssertTrue(true)
    }
}

extension WechatHandlerBaseTests {

    func test_isAutoResend(_ value: Bool) {
        XCTAssertEqual(value, false)
    }

    func test_result(_ value: String) {
        XCTAssertEqual(value, "1")
    }

    func test_returnFromApp(_ value: String) {
        XCTAssertEqual(value, "0")
    }

    func test_sdkver(_ value: String) {
        XCTAssertEqual(value, sdkVersion)
    }

    func test_universalLink(_ value: String) {
        XCTAssertEqual(value, universalLink.absoluteString)
    }
}

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

// MARK: - Share - Common - UniversalLink

extension WechatHandlerBaseTests: ShareCommonUniversalLinkTestCase {

    func test_share_common_ul(path: String) {
        XCTAssertEqual(path, "/app/\(appID)/sendreq/")
    }

    func test_share_common_ul(queryItems: inout [URLQueryItem]) {
        XCTAssertTrue(true)
    }
}

// MARK: - Share - MediaMessage - UniversalLink

extension WechatHandlerBaseTests: ShareMediaMessageUniversalLinkTestCase {

    func test_share_media_ul(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint) {
        XCTAssertTrue(true)
    }
}

// MARK: - Share - Message - UniversalLink

extension WechatHandlerBaseTests: ShareMessageUniversalLinkTestCase {

    func test_share_message_ul(queryItems: inout [URLQueryItem], _ message: MessageType, _ endpoint: Endpoint) {
        XCTAssertTrue(true)
    }
}

// MARK: - Share - Common - Pasteboard

extension WechatHandlerBaseTests: ShareCommonPasteboardTestCase {

    func test_share_common_pb(dictionary: inout [String: Any]) {
        XCTAssertTrue(true)
    }
}

// MARK: - Share - MediaMessage - Pasteboard

extension WechatHandlerBaseTests: ShareMediaMessagePasteboardTestCase {

    func test_share_media_pb(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        let appbrandissecrectmessage = dictionary.removeValue(forKey: "appbrandissecrectmessage") as? Bool
        test_appbrandissecrectmessage(appbrandissecrectmessage, message)

        let appbrandisupdatablemessage = dictionary.removeValue(forKey: "appbrandisupdatablemessage") as? Bool
        test_appbrandisupdatablemessage(appbrandisupdatablemessage, message)

        let description = dictionary.removeValue(forKey: "description") as? String
        test_description(description, message)

        let disableForward = dictionary.removeValue(forKey: "disableForward") as? Bool
        test_disableForward(disableForward, message)

        let miniprogramType = dictionary.removeValue(forKey: "miniprogramType") as? Int
        test_miniprogramType(miniprogramType, message)

        let musicVideoDuration = dictionary.removeValue(forKey: "musicVideoDuration") as? String
        test_musicVideoDuration(musicVideoDuration, message)

        let musicVideoIssueData = dictionary.removeValue(forKey: "musicVideoIssueData") as? String
        test_musicVideoIssueData(musicVideoIssueData, message)

        let objectType = dictionary.removeValue(forKey: "objectType") as? String
        test_objectType(objectType, message)

        let thumbData = dictionary.removeValue(forKey: "thumbData") as? Data
        test_thumbData(thumbData, message)

        let weworkObjectSubType = dictionary.removeValue(forKey: "weworkObjectSubType") as? String
        test_weworkObjectSubType(weworkObjectSubType, message)

        let withShareTicket = dictionary.removeValue(forKey: "withShareTicket") as? Bool
        test_withShareTicket(withShareTicket, message)
    }
}

extension WechatHandlerBaseTests {

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
            XCTAssertEqual(value!, false)
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
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
            XCTAssertEqual(value!, false)
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
        }
    }

    func test_description(_ value: String?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(value)
        case let message as ImageMessage:
            XCTAssertEqual(value!, message.description)
        case let message as AudioMessage:
            XCTAssertEqual(value!, message.description)
        case let message as VideoMessage:
            XCTAssertEqual(value!, message.description)
        case let message as WebPageMessage:
            XCTAssertEqual(value!, message.description)
        case let message as FileMessage:
            XCTAssertEqual(value!, message.description)
        case let message as MiniProgramMessage:
            XCTAssertEqual(value!, message.description)
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
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
            XCTAssertEqual(value!, false)
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
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
            XCTAssertEqual(value!, 0)
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
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
            XCTAssertEqual(value!, "0")
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
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
            XCTAssertEqual(value!, "0")
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
        }
    }

    func test_objectType(_ value: String?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(value)
        case is ImageMessage:
            XCTAssertEqual(value!, "2")
        case is AudioMessage:
            XCTAssertEqual(value!, "3")
        case is VideoMessage:
            XCTAssertEqual(value!, "4")
        case is WebPageMessage:
            XCTAssertEqual(value!, "5")
        case is FileMessage:
            XCTAssertEqual(value!, "6")
        case is MiniProgramMessage:
            XCTAssertEqual(value!, "36")
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
        }
    }

    func test_thumbData(_ value: Data?, _ message: MessageType) {
        switch message {
        case is TextMessage:
            XCTAssertNil(value)
        case let message as ImageMessage:
            XCTAssertEqual(value!, message.thumbnail)
        case let message as AudioMessage:
            XCTAssertEqual(value!, message.thumbnail)
        case let message as VideoMessage:
            XCTAssertEqual(value!, message.thumbnail)
        case let message as WebPageMessage:
            XCTAssertEqual(value!, message.thumbnail)
        case let message as FileMessage:
            XCTAssertEqual(value!, message.thumbnail)
        case let message as MiniProgramMessage:
            XCTAssertEqual(value!, message.thumbnail)
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
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
            XCTAssertEqual(value!, "0")
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
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
            XCTAssertEqual(value!, false)
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
        }
    }
}

// MARK: - Share - Message - Pasteboard

extension WechatHandlerBaseTests: ShareMessagePasteboardTestCase {

    func test_share_message_pb(dictionary: inout [String: Any], _ message: MessageType, _ endpoint: Endpoint) {
        let appBrandPath = dictionary.removeValue(forKey: "appBrandPath") as? String
        test_appBrandPath(appBrandPath, message)

        let appBrandUserName = dictionary.removeValue(forKey: "appBrandUserName") as? String
        test_appBrandUserName(appBrandUserName, message)

        let command = dictionary.removeValue(forKey: "command") as! String
        test_command(command, message)

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

        let scene = dictionary.removeValue(forKey: "scene") as! String
        test_scene(scene, endpoint)

        let title = dictionary.removeValue(forKey: "title") as! String
        test_title(title, message)
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
            XCTAssertEqual(value!, message.path)
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
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
            XCTAssertEqual(value!, message.miniProgramID)
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
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
            XCTAssertTrue(false, "\(String(describing: value))")
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
            XCTAssertEqual(value, message.data)
        case let message as FileMessage:
            XCTAssertEqual(value, message.data)
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
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
            XCTAssertEqual(value, message.fileExtension)
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
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
            XCTAssertEqual(value!, message.thumbnail)
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
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
            XCTAssertEqual(value!, message.dataLink?.absoluteString)
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
        }
    }

    func test_mediaUrl(_ value: String?, _ message: MessageType) {
        switch message {
        case is TextMessage,
             is ImageMessage,
             is FileMessage:
            XCTAssertNil(value)
        case let message as AudioMessage:
            XCTAssertEqual(value!, message.link.absoluteString)
        case let message as VideoMessage:
            XCTAssertEqual(value!, message.link.absoluteString)
        case let message as WebPageMessage:
            XCTAssertEqual(value!, message.link.absoluteString)
        case let message as MiniProgramMessage:
            XCTAssertEqual(value!, message.link.absoluteString)
        default:
            XCTAssertTrue(false, "\(String(describing: value))")
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
            XCTAssertTrue(false, "\(String(describing: value))")
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
            XCTAssertTrue(false, "\(String(describing: value))")
        }
    }
}

// MARK: - Share - Completion

extension WechatHandlerBaseTests: ShareCompletionTestCase {

    func test_share_avoid_error(_ error: Bus.Error, _ message: MessageType, _ endpoint: Endpoint) -> Bool {
        (message.identifier == Messages.file && endpoint == Endpoints.Wechat.timeline)
            || (message.identifier == Messages.miniProgram && endpoint == Endpoints.Wechat.timeline)
            || (message.identifier == Messages.miniProgram && endpoint == Endpoints.Wechat.favorite)
    }
}

// MARK: - Oauth

extension WechatHandlerBaseTests: OauthTestCase {

    func test_oauth() {
        test_oauth(Platforms.wechat)
    }
}

// MARK: - Oauth - Platform - UniversalLink

extension WechatHandlerBaseTests: OauthPlatformUniversalLinkTestCase {

    func test_oauth_ul(path: String) {
        XCTAssertEqual(path, "/app/\(appID)/auth/")
    }

    func test_oauth_ul(queryItems: inout [URLQueryItem], _ platform: Platform) {
        let scope = queryItems.removeFirst { $0.name == "scope" }!
        test_scope(scope)

        let state = queryItems.removeFirst { $0.name == "state" }!
        test_state(state)
    }
}

extension WechatHandlerBaseTests {

    func test_scope(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, "snsapi_userinfo")
    }

    func test_state(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, "")
    }
}

// MARK: - Oauth - Platform - Pasteboard

extension WechatHandlerBaseTests: OauthPlatformPasteboardTestCase {

    func test_oauth_pb(dictionary: inout [String: Any], _ platform: Platform) {
        let command = dictionary.removeValue(forKey: "command") as! String
        test_command_oauth(command)
    }
}

extension WechatHandlerBaseTests {

    func test_command_oauth(_ value: String) {
        XCTAssertEqual(value, "0")
    }
}

// MARK: - Launch

extension WechatHandlerBaseTests: LaunchTestCase {

    func test_launch() {
        test_launch(Platforms.wechat, MediaSource.wechatMiniProgram as! MiniProgramMessage)
    }
}

// MARK: - Launch - URL

extension WechatHandlerBaseTests: LaunchURLTestCase {

    func test_launch_ul(path: String) {
        XCTAssertEqual(path, "/app/\(appID)/jumpWxa/")
    }

    func test_launch_ul(queryItems: inout [URLQueryItem], _ platform: Platform, _ program: MiniProgramMessage) {
        let extMsg = queryItems.removeFirst { $0.name == "extMsg" }!
        test_extMsg(extMsg)

        let miniProgramType = queryItems.removeFirst { $0.name == "miniProgramType" }!
        test_miniProgramType(miniProgramType, program)

        let path = queryItems.removeFirst { $0.name == "path" }!
        test_path(path, program)

        let userName = queryItems.removeFirst { $0.name == "userName" }!
        test_userName(userName, program)
    }
}

extension WechatHandlerBaseTests {

    func test_extMsg(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, "")
    }

    func test_miniProgramType(_ queryItem: URLQueryItem, _ message: MessageType) {
        let miniProgramType: (MiniProgramMessage.MiniProgramType) -> String = { miniProgramType in
            switch miniProgramType {
            case .release:
                return "0"
            case .test:
                return "1"
            case .preview:
                return "2"
            }
        }

        switch message {
        case let message as MiniProgramMessage:
            XCTAssertEqual(queryItem.value!, miniProgramType(message.miniProgramType))
        default:
            XCTAssertTrue(false, "\(String(describing: queryItem.value))")
        }
    }

    func test_path(_ queryItem: URLQueryItem, _ message: MessageType) {
        switch message {
        case let message as MiniProgramMessage:
            XCTAssertEqual(queryItem.value!, message.path)
        default:
            XCTAssertTrue(false, "\(String(describing: queryItem.value))")
        }
    }

    func test_userName(_ queryItem: URLQueryItem, _ message: MessageType) {
        switch message {
        case let message as MiniProgramMessage:
            XCTAssertEqual(queryItem.value!, message.miniProgramID)
        default:
            XCTAssertTrue(false, "\(String(describing: queryItem.value))")
        }
    }
}

// MARK: - Launch - Pasteboard

extension WechatHandlerBaseTests: LaunchPasteboardTestCase {

    func test_launch_pb(dictionary: inout [String: Any], _ platform: Platform, _ program: MiniProgramMessage) {
        let command = dictionary.removeValue(forKey: "command") as! String
        test_command_launch(command)
    }
}

extension WechatHandlerBaseTests {

    func test_command_launch(_ value: String) {
        XCTAssertEqual(value, "1080")
    }
}
