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
            .map { _ in base.items }
    }
}
