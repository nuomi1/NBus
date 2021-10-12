//
//  AppDelegateSDK.swift
//  NBus
//
//  Created by nuomi1 on 2021/10/12.
//  Copyright © 2021 nuomi1. All rights reserved.
//

import UIKit

#if BusMockQQSDK
import NBusQQSDK
#elseif BusMockWechatSDK
import NBusWechatSDK
#elseif BusMockWeiboSDK
import NBusWeiboSDK
#endif

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

        #if BusMockQQSDK
        let title = "isQQInstalled"
        let message = "\(QQApiInterface.isQQInstalled())"
        #elseif BusMockWechatSDK
        let title = "isWXAppInstalled"
        let message = "\(WXApi.isWXAppInstalled())"
        #elseif BusMockWeiboSDK
        let title = "isWeiboAppInstalled"
        let message = "\(WeiboSDK.isWeiboAppInstalled())"
        #else
        #error("ERROR")
        let title = "ERROR"
        let message = "ERROR"
        #endif

        let alert = UIAlertController(
            title: title,
            message: message,
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
