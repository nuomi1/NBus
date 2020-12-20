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

        let endpoints: Observable<[Endpoint]>
        let currentEndpoint: BehaviorRelay<Endpoint?>

        let platform: BehaviorRelay<Platform>
        let oauthInfo: BehaviorRelay<OauthInfo>

        let isShareEnabled: Observable<Bool>
        let isOauthEnabled: Observable<Bool>

        init(_ element: AppState.PlatformItem) {
            title = .just("\(element.platform)")

            endpoints = .just(element.endpoints ?? [])
            currentEndpoint = .init(value: nil)

            platform = .init(value: element.platform)
            oauthInfo = .init(value: Self.defaultOauthInfo)

            isShareEnabled = .just(element.handler is ShareHandlerType)
            isOauthEnabled = .just(element.handler is OauthHandlerType)
        }

        static let defaultOauthInfo = OauthInfo(isLogin: false, parameter: "未登录")
    }
}

private extension AppState.PlatformItem {

    var endpoints: [Endpoint]? {
        (handler as? ShareHandlerType)?.endpoints
    }
}
