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

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

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
        return Bus.shared.openURL(url)
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        return Bus.shared.openUserActivity(userActivity)
    }
}

extension AppDelegate {

    private func pasteboardItems() -> Observable<[[String]]> {
        NotificationCenter.default.rx
            .notification(UIPasteboard.changedNotification)
            .map { _ -> [[String]] in
                UIPasteboard.general.items.map { item -> [String] in
                    item.map { key, value -> String in
                        switch value {
                        case let data as Data:
                            if
                                let plist = try? PropertyListSerialization.propertyList(
                                    from: data,
                                    options: [],
                                    format: nil
                                ) {
                                return "\(key), \(plist)"
                            } else if
                                let string = String(
                                    data: data,
                                    encoding: .utf8
                                ) {
                                return "\(key), \(string)"
                            } else {
                                assertionFailure()
                                return "\(key), \(value)"
                            }
                        case let string as String:
                            return "\(key), \(string)"
                        default:
                            assertionFailure()
                            return "\(key), \(value)"
                        }
                    }
                }
            }
            .distinctUntilChanged()
    }
}

extension AppDelegate {

    private func observeQQ() {
        SwiftTrace.traceClasses(matchingPattern: "^QQ")
        SwiftTrace.traceClasses(matchingPattern: "^Tencent")

        _ = pasteboardItems()
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .takeUntil(rx.deallocating)
            .bind(onNext: { items in
                logger.debug("\(items)")
            })
    }
}
