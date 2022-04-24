//
//  Reactive.swift
//  NBus
//
//  Created by nuomi1 on 2022/4/1.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension Reactive where Base: UIApplication {

    func canOpenURL() -> Observable<URL> {
        methodInvoked(#selector(UIApplication.canOpenURL(_:)))
            .compactMap { args in
                args[0] as? URL
            }
    }

    func openURL() -> Observable<URL> {
        let oldURL = methodInvoked(#selector(UIApplication.openURL(_:)))
            .compactMap { args in
                args[0] as? URL
            }

        let newURL = methodInvoked(#selector(UIApplication.open(_:options:completionHandler:)))
            .compactMap { args in
                args[0] as? URL
            }

        return Observable.merge([oldURL, newURL])
    }
}

extension Reactive where Base: UIPasteboard {

    func items() -> Observable<[[String: Any]]> {
        NotificationCenter.default.rx
            .notification(UIPasteboard.changedNotification)
            .observe(on: MainScheduler.asyncInstance)
            .filter { ($0.object as! UIPasteboard) == base }
            .map { _ in base.items }
    }
}

extension Reactive where Base: NotificationCenter {

    func openURL() -> Observable<URL> {
        notification(AppState.OpenURL.requestName)
            .map { $0.userInfo?[AppState.OpenURL.requestURLKey] as! URL }
    }

    func openUserActivity() -> Observable<NSUserActivity> {
        notification(AppState.OpenUserActivity.requestName)
            .map { $0.userInfo?[AppState.OpenUserActivity.requestUserActivityKey] as! NSUserActivity }
    }
}
