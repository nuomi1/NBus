//
//  ViewController+ViewModel.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import RxSwift
import UIKit

extension ViewController {

    class ViewModel {

        let title: Observable<String>
        let platformItems: Observable<[AppState.PlatformItem]>

        init(_ element: [AppState.PlatformItem]) {
            title = .just("BusMock")

            platformItems = .just(element)
        }
    }
}
