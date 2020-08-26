//
//  PlatformViewController.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import NBus
import RxSwift
import UIKit

class PlatformViewController: UIViewController {

    enum Constant {

        static let buttonType: UIButton.ButtonType = .system

        static let widthMultiple: CGFloat = 1.5

        static let spacing: CGFloat = 22

        static let borderColor = UIButton(type: .system).currentTitleColor.cgColor
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 4
    }

    private var viewModel: ViewModel?

    private let disposeBag = DisposeBag()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let shareView = TitleContentView(title: "分享", contentView: ShareView())
    private let oauthView = TitleContentView(title: "登录", contentView: OauthView())
}

extension PlatformViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupSubviews()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        scrollView.pin
            .all()

        contentView.pin
            .horizontally(scrollView.pin.safeArea)

        shareView.pin
            .horizontally()
            .sizeToFit(.width)

        oauthView.pin
            .horizontally()
            .sizeToFit(.width)
            .below(of: shareView)

        let minHeight = scrollView.bounds.size.height
            - scrollView.pin.safeArea.top
            - scrollView.pin.safeArea.bottom

        contentView.pin
            .wrapContent(.vertically)
            .minHeight(minHeight)

        scrollView.contentSize = contentView.bounds.size
    }

    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(shareView)
        contentView.addSubview(oauthView)
    }
}

extension PlatformViewController {

    func binding(_ viewModel: ViewModel) {
        self.viewModel = viewModel

        viewModel.title
            .bind(to: rx.title)
            .disposed(by: disposeBag)

        shareView.contentView.binding(viewModel)
        shareView.contentView.onShare = { [weak self] message, endpoint, view in
            let options: [Bus.ShareOptionKey: Any] = {
                var output: [Bus.ShareOptionKey: Any?] = [:]

                if self?.viewModel?.platform.value == Platforms.system {
                    output[SystemHandler.ShareOptionKeys.sourceView] = view
                }

                return output.compactMapValues { $0 }
            }()

            self?.share(message: message, to: endpoint, options: options)
        }

        oauthView.contentView.binding(viewModel)
        oauthView.contentView.onOauth = { [weak self] platform in
            self?.oauth(with: platform)
        }
    }
}

extension PlatformViewController {

    private func share(message: MessageType, to endpoint: Endpoint, options: [Bus.ShareOptionKey: Any]) {
        Bus.shared.share(message: message, to: endpoint, options: options) { [weak self] result in
            guard let self = self else { return }

            let alert: UIAlertController

            switch result {
            case .success:
                alert = UIAlertController(
                    title: "Success",
                    message: nil,
                    preferredStyle: .alert
                )
            case let .failure(error):
                alert = UIAlertController(
                    title: "Failure",
                    message: "\(error)",
                    preferredStyle: .alert
                )
            }

            let okAction = UIAlertAction(
                title: "OK",
                style: .default
            )

            alert.addAction(okAction)

            self.present(alert, animated: true)
        }
    }

    private func oauth(with platform: Platform) {
        guard viewModel?.oauthInfo.value.isLogin == false else {
            viewModel?.oauthInfo
                .accept(ViewModel.defaultOauthInfo)

            return
        }

        Bus.shared.oauth(with: platform) { [weak self] result in
            guard let self = self else { return }

            let alert: UIAlertController

            switch result {
            case let .success(parameters):
                alert = UIAlertController(
                    title: "Success",
                    message: "\(parameters)",
                    preferredStyle: .alert
                )

                self.viewModel?.oauthInfo
                    .accept(.init(isLogin: true, parameter: "\(parameters)"))
            case let .failure(error):
                alert = UIAlertController(
                    title: "Failure",
                    message: "\(error)",
                    preferredStyle: .alert
                )

                self.viewModel?.oauthInfo
                    .accept(.init(isLogin: false, parameter: "\(error)"))
            }

            let okAction = UIAlertAction(
                title: "OK",
                style: .default
            )

            alert.addAction(okAction)

            self.present(alert, animated: true)
        }
    }
}
