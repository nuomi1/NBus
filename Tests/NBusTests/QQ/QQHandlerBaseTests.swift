//
//  QQHandlerBaseTests.swift
//  BusTests
//
//  Created by nuomi1 on 2022/3/30.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
@testable import NBus
import RxSwift
import XCTest

class QQHandlerBaseTests: HandlerBaseTests {

    override var appID: String {
        switch handler {
        case let handler as QQSDKHandler:
            return handler.appID
        case let handler as QQHandler:
            return handler.appID
        default:
            fatalError()
        }
    }

    override var sdkShortVersion: String {
        "3.5.11"
    }

    override var sdkVersion: String {
        "3.5.11_lite"
    }

    var statusMachine: String {
        UIDevice.current.bus.machine
    }

    var statusOS: String {
        UIDevice.current.systemVersion
    }

    var statusVersion: String {
        "\(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)"
    }

    var txID: String {
        "QQ\(String(format: "%08llX", (appNumber as NSString).longLongValue))"
    }

    override var universalLink: URL {
        switch handler {
        case let handler as QQSDKHandler:
            return handler.universalLink
        case let handler as QQHandler:
            return handler.universalLink
        default:
            fatalError()
        }
    }
}

// MARK: - Share

extension QQHandlerBaseTests {

    func test_share(_ message: MessageType, _ endpoint: Endpoint) {
        UIApplication.shared.rx
            .openURL()
            .bind(onNext: { [unowned self] url in
                self.test_share(url: url, message, endpoint)
            })
            .disposed(by: disposeBag)

        UIPasteboard.general.rx
            .items()
            .bind(onNext: { [unowned self] items in
                self.test_share(items: items, message, endpoint)
            })
            .disposed(by: disposeBag)

        Bus.shared.share(
            message: message,
            to: endpoint,
            completionHandler: { result in
                switch result {
                case .success:
                    XCTAssertTrue(true)
                case let .failure(error):
                    logger.error("\(error)")

                    if message.identifier == Messages.file, endpoint == Endpoints.QQ.timeline {
                        XCTAssertTrue(true)
                    } else {
                        XCTAssertTrue(false)
                    }
                }
            }
        )
    }

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

// MARK: Share - UniversalLink

extension QQHandlerBaseTests {

    func test_share(url: URL, _ message: MessageType, _ endpoint: Endpoint) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = urlComponents.queryItems ?? []

        // GeneralUniversalLink

        XCTAssertEqual(urlComponents.scheme, "https")
        XCTAssertEqual(urlComponents.host, "qm.qq.com")

        let appsign_txid = queryItems.removeFirst { $0.name == "appsign_txid" }!
        test_appsign_txid(appsign_txid)

        let bundleid = queryItems.removeFirst { $0.name == "bundleid" }!
        test_bundleid(bundleid)

        let sdkv = queryItems.removeFirst { $0.name == "sdkv" }!
        test_sdkv(sdkv)

        // ShareUniversalLink

        XCTAssertEqual(urlComponents.path, "/opensdkul/mqqapi/share/to_fri")

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

        // share

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

        let pasteboard = queryItems.removeFirst { $0.name == "pasteboard" }
        test_pasteboard(pasteboard, message)

        let shareType = queryItems.removeFirst { $0.name == "shareType" }!
        test_shareType(shareType, message, endpoint)

        let title = queryItems.removeFirst { $0.name == "title" }
        test_title(title, message)

        let url = queryItems.removeFirst { $0.name == "url" }
        test_url(url, message)

        logger.debug("\(URLComponents.self), \(message.identifier), \(endpoint), \(queryItems.map(\.name).sorted())")
        XCTAssertTrue(queryItems.isEmpty)
    }
}

extension QQHandlerBaseTests {

    func test_appsign_txid(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, txID)
    }

    func test_bundleid(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, bundleID.bus.base64EncodedString)
    }

    func test_callback_name(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, txID)
    }

    func test_callback_type(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, "scheme")
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

    func test_sdkv(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, sdkShortVersion)
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

    func test_src_type(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, "app")
    }

    func test_thirdAppDisplayName(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, displayName.bus.base64EncodedString)
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

    func test_version(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, "1")
    }
}

// MARK: Share - Pasteboard

extension QQHandlerBaseTests {

    func test_share(items: [[String: Any]], _ message: MessageType, _ endpoint: Endpoint) {
        if items.isEmpty {
            XCTAssertTrue(true)
            return
        }

        let data = items.first!["com.tencent.mqq.api.apiLargeData"] as! Data
        var dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: Any]

        let file_data = dictionary.removeValue(forKey: "file_data") as? Data
        test_file_data(file_data, message)

        let previewimagedata = dictionary.removeValue(forKey: "previewimagedata") as? Data
        test_previewimagedata(previewimagedata, message)

        logger.debug("\(UIPasteboard.self), \(message.identifier), \(endpoint), \(dictionary.keys.sorted())")
        XCTAssertTrue(dictionary.isEmpty)
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

// MARK: - Oauth

extension QQHandlerBaseTests {

    func test_oauth() {
        UIApplication.shared.rx
            .openURL()
            .bind(onNext: { [unowned self] url in
                self.test_oauth(url: url)
            })
            .disposed(by: disposeBag)

        UIPasteboard.general.rx
            .items()
            .bind(onNext: { [unowned self] items in
                self.test_oauth(items: items)
            })
            .disposed(by: disposeBag)

        Bus.shared.oauth(
            with: Platforms.qq,
            completionHandler: { result in
                switch result {
                case .success:
                    XCTAssertTrue(true)
                case .failure:
                    XCTAssertTrue(false)
                }
            }
        )
    }
}

// MARK: Oauth - UniversalLink

extension QQHandlerBaseTests {

    func test_oauth(url: URL) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = urlComponents.queryItems ?? []

        // GeneralUniversalLink

        XCTAssertEqual(urlComponents.scheme, "https")
        XCTAssertEqual(urlComponents.host, "qm.qq.com")

        let appsign_txid = queryItems.removeFirst { $0.name == "appsign_txid" }!
        test_appsign_txid(appsign_txid)

        let bundleid = queryItems.removeFirst { $0.name == "bundleid" }!
        test_bundleid(bundleid)

        let sdkv = queryItems.removeFirst { $0.name == "sdkv" }!
        test_sdkv(sdkv)

        // OauthUniversalLink

        XCTAssertEqual(urlComponents.path, "/opensdkul/mqqOpensdkSSoLogin/SSoLogin/\(appID)")

        let objectlocation = queryItems.removeFirst { $0.name == "objectlocation" }!
        test_objectlocation(objectlocation)

        let pasteboard = queryItems.removeFirst { $0.name == "pasteboard" }!
        test_pasteboard(pasteboard)

        logger.debug("\(URLComponents.self), \(queryItems.map(\.name).sorted())")
        XCTAssertTrue(queryItems.isEmpty)
    }
}

extension QQHandlerBaseTests {

    func test_objectlocation(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value, "url")
    }

    func test_pasteboard(_ queryItem: URLQueryItem) {
        let data = Data(base64Encoded: queryItem.value!)!
        var object = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: Any]

        let appsign_token = object.removeValue(forKey: "appsign_token") as! String
        XCTAssertEqual(appsign_token, "")

        let app_id = object.removeValue(forKey: "app_id") as! String
        XCTAssertEqual(app_id, appNumber)

        let app_name = object.removeValue(forKey: "app_name") as! String
        XCTAssertEqual(app_name, displayName)

        let bundleid = object.removeValue(forKey: "bundleid") as! String
        XCTAssertEqual(bundleid, bundleID)

        let client_id = object.removeValue(forKey: "client_id") as! String
        XCTAssertEqual(client_id, appNumber)

        let refUniversallink = object.removeValue(forKey: "refUniversallink") as! String
        XCTAssertEqual(refUniversallink, universalLink.absoluteString)

        let response_type = object.removeValue(forKey: "response_type") as! String
        XCTAssertEqual(response_type, "token")

        let scope = object.removeValue(forKey: "scope") as! String
        XCTAssertEqual(scope, "get_user_info")

        let sdkp = object.removeValue(forKey: "sdkp") as! String
        XCTAssertEqual(sdkp, "i")

        let sdkv = object.removeValue(forKey: "sdkv") as! String
        XCTAssertEqual(sdkv, sdkVersion)

        let status_machine = object.removeValue(forKey: "status_machine") as! String
        XCTAssertEqual(status_machine, statusMachine)

        let status_os = object.removeValue(forKey: "status_os") as! String
        XCTAssertEqual(status_os, statusOS)

        let status_version = object.removeValue(forKey: "status_version") as! String
        XCTAssertEqual(status_version, statusVersion)

        logger.debug("\(URLComponents.self), \(object.keys.sorted())")
        XCTAssertTrue(object.isEmpty)
    }
}

// MARK: Oauth - Pasteboard

extension QQHandlerBaseTests {

    func test_oauth(items: [[String: Any]]) {
        if items.isEmpty {
            XCTAssertTrue(true)
            return
        }

        let data = items.first!["com.tencent.mqq.api.apiLargeData"]

        logger.debug("\(UIPasteboard.self), \(items.map(\.keys))")
        XCTAssertNil(data)
    }
}

// MARK: - Launch

extension QQHandlerBaseTests {

    func test_launch() {
        let message = MediaSource.qqMiniProgram as! MiniProgramMessage

        UIApplication.shared.rx
            .openURL()
            .bind(onNext: { [unowned self] url in
                self.test_launch(url: url, message)
            })
            .disposed(by: disposeBag)

        UIPasteboard.general.rx
            .items()
            .bind(onNext: { [unowned self] items in
                self.test_launch(items: items)
            })
            .disposed(by: disposeBag)

        Bus.shared.launch(
            program: message,
            with: Platforms.qq,
            completionHandler: { result in
                switch result {
                case .success:
                    XCTAssertTrue(true)
                case .failure:
                    XCTAssertTrue(false)
                }
            }
        )
    }
}

// MARK: Launch - UniversalLink

extension QQHandlerBaseTests {

    func test_launch(url: URL, _ message: MessageType) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = urlComponents.queryItems ?? []

        // GeneralUniversalLink

        XCTAssertEqual(urlComponents.scheme, "https")
        XCTAssertEqual(urlComponents.host, "qm.qq.com")

        let appsign_txid = queryItems.removeFirst { $0.name == "appsign_txid" }!
        test_appsign_txid(appsign_txid)

        let bundleid = queryItems.removeFirst { $0.name == "bundleid" }!
        test_bundleid(bundleid)

        let sdkv = queryItems.removeFirst { $0.name == "sdkv" }!
        test_sdkv(sdkv)

        // LaunchUniversalLink

        XCTAssertEqual(urlComponents.path, "/opensdkul/mqqapi/profile/sdk_launch_mini_app")

        let appid = queryItems.removeFirst { $0.name == "appid" }!
        test_appid(appid)

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

        // launch

        let mini_appid = queryItems.removeFirst { $0.name == "mini_appid" }!
        test_mini_appid(mini_appid, message)

        let mini_path = queryItems.removeFirst { $0.name == "mini_path" }!
        test_mini_path(mini_path, message)

        let mini_type = queryItems.removeFirst { $0.name == "mini_type" }!
        test_mini_type(mini_type, message)

        logger.debug("\(URLComponents.self), \(queryItems.map(\.name).sorted())")
        XCTAssertTrue(queryItems.isEmpty)
    }
}

extension QQHandlerBaseTests {

    func test_appid(_ queryItem: URLQueryItem) {
        XCTAssertEqual(queryItem.value!, appNumber)
    }
}

// MARK: Launch - Pasteboard

extension QQHandlerBaseTests {

    func test_launch(items: [[String: Any]]) {
        if items.isEmpty {
            XCTAssertTrue(true)
            return
        }

        let data = items.first!["com.tencent.mqq.api.apiLargeData"]

        logger.debug("\(UIPasteboard.self), \(items.map(\.keys))")
        XCTAssertNil(data)
    }
}
