//
//  AppDelegate.swift
//  NBus
//
//  Created by nuomi1 on 07/10/2020.
//  Copyright (c) 2020 nuomi1. All rights reserved.
//

import NBus
import PinLayout
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

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

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return Bus.shared.openURL(url)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return Bus.shared.openUserActivity(userActivity)
    }
}
