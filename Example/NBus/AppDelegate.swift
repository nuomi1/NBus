//
//  AppDelegate.swift
//  NBus
//
//  Created by nuomi1 on 07/10/2020.
//  Copyright (c) 2020 nuomi1. All rights reserved.
//

import NBus
import PinLayout
import RxCocoa
import RxSwift
import SwiftTrace
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let disposeBag = DisposeBag()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        clearStorage()

//        observeSDK()

        AppState.shared.setup()

        let viewController = ViewController()
        viewController.binding(.init(AppState.shared.platformItems.value))

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.view.backgroundColor = .white

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        UIPasteboard.general.items = UIPasteboard.general.items
        logger.debug("\(url)")
        return Bus.shared.openURL(url)
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        UIPasteboard.general.items = UIPasteboard.general.items
        logger.debug("\(userActivity.webpageURL!)")
        return Bus.shared.openUserActivity(userActivity)
    }
}

extension AppDelegate {

    // swiftlint:disable function_body_length

    private func pasteboardItems() -> Observable<[[String]]> {
        UIPasteboard.general.rx
            .items()
            .map { items -> [[String]] in
                items.enumerated().map { index, item -> [String] in
                    item.map { key, value -> String in
                        let identity: String
                        let index = "(\(index + 1)/\(items.count))"
                        let content: String

                        switch value {
                        case let data as Data:
                            if
                                let string = String(
                                    data: data,
                                    encoding: .utf8
                                ) {
                                identity = "[Data-String]"
                                content = string
                            } else if
                                let object = NSKeyedUnarchiver.unarchiveObject(
                                    with: data
                                ) {
                                identity = "[Data-Keyed]"
                                content = "\(object)"
                            } else if
                                let plist = try? PropertyListSerialization.propertyList(
                                    from: data,
                                    options: [],
                                    format: nil
                                ) {
                                identity = "[Data-Plist]"
                                content = "\(plist)"
                            } else {
                                assertionFailure()
                                identity = "[Data-Unknown]"
                                content = "\(value)"
                            }
                        case let string as String:
                            identity = "[String]"
                            content = "\(string)"
                        default:
                            assertionFailure()
                            identity = "[Unknown]"
                            content = "\(value)"
                        }

                        return "\(identity)\(index), \(key), \(content)"
                    }
                }
            }
            .distinctUntilChanged()
    }

    // swiftlint:enable function_body_length
}

extension AppDelegate {

    private func observeSystem() {
        pasteboardItems()
            .bind(onNext: { items in
                logger.debug("\(items)")
            })
            .disposed(by: disposeBag)

        UIApplication.shared.rx
            .canOpenURL()
            .bind(onNext: { url in
                logger.debug("\(url)")
            })
            .disposed(by: disposeBag)

        UIApplication.shared.rx
            .openURL()
            .bind(onNext: { url in
                logger.debug("\(url)")
            })
            .disposed(by: disposeBag)
    }
}

extension AppDelegate {

    private func clearKeychains() {
        let items = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity,
        ]

        let status = items
            .map { [kSecClass: $0] as CFDictionary }
            .map { SecItemDelete($0) }

        assert(status.allSatisfy {
            $0 == errSecSuccess || $0 == errSecItemNotFound
        })
    }

    private func clearPasteboard() {
        let pasteboard = UIPasteboard.general

        pasteboard.items = []

        pasteboard.string = "NBus"
    }

    private func clearUserDefaults() {
        let defaults = UserDefaults.standard

        for (key, _) in defaults.dictionaryRepresentation() {
            defaults.removeObject(forKey: key)
        }
    }
}

extension AppDelegate {

    private func clearStorage() {
        clearKeychains()
        clearPasteboard()
        clearUserDefaults()
    }
}

extension AppDelegate {

    private func observeSDK() {
//        SwiftTrace.traceClasses(matchingPattern: "^QQ")
//        SwiftTrace.traceClasses(matchingPattern: "^Tencent")

//        SwiftTrace.traceClasses(matchingPattern: "^WB")
//        SwiftTrace.traceClasses(matchingPattern: "^Weibo")

        observeSystem()
    }
}
