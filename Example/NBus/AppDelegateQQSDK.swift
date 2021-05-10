//
//  AppDelegateQQSDK.swift
//  NBus
//
//  Created by nuomi1 on 2021/5/10.
//  Copyright © 2021 nuomi1. All rights reserved.
//

import NBusQQSDK
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let viewController = UIViewController()

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.view.backgroundColor = .white

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        let alert = UIAlertController(
            title: "isQQInstalled",
            message: "\(QQApiInterface.isQQInstalled())",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { [weak alert] _ in
            alert?.dismiss(animated: true, completion: nil)
        })
        alert.addAction(cancelAction)

        navigationController.present(alert, animated: true, completion: nil)

        return true
    }
}
