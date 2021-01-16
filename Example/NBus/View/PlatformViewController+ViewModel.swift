//
//  PlatformViewController+ViewModel.swift
//
//
//  Created by nuomi1 on 2020/8/26.
//

import NBus
import RxRelay
import RxSwift
import UIKit

extension PlatformViewController {

    class ViewModel {

        struct OauthInfo {
            let isLogin: Bool
            let parameter: String
        }

        let title: Observable<String>

        let isSwitchEnabled: Observable<Bool>
        let currentCategory: BehaviorRelay<AppState.PlatformItem.Category>
        let currentHandler: Observable<HandlerType>

        let endpoints: Observable<[Endpoint]>
        let currentEndpoint: BehaviorRelay<Endpoint?>

        let platform: BehaviorRelay<Platform>
        let oauthInfo: BehaviorRelay<OauthInfo>

        let isShareEnabled: Observable<Bool>
        let isOauthEnabled: Observable<Bool>

        init(_ element: AppState.PlatformItem) {
            title = .just("\(element.platform)")

            isSwitchEnabled = .just(element.handlers.count > 1)
            currentCategory = .init(value: element.category)
            currentHandler = currentCategory
                .compactMap { element.handlers[$0] }

            endpoints = currentHandler
                .compactMap { $0 as? ShareHandlerType }
                .map { $0.endpoints }
            currentEndpoint = .init(value: nil)

            platform = .init(value: element.platform)
            oauthInfo = .init(value: Self.defaultOauthInfo)

            isShareEnabled = currentHandler
                .map { $0 is ShareHandlerType }
            isOauthEnabled = currentHandler
                .map { $0 is OauthHandlerType }
        }

        static let defaultOauthInfo = OauthInfo(isLogin: false, parameter: "未登录")
    }
}
