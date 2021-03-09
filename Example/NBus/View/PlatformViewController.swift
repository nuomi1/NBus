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

    private let handlerBarButtonItem = UIBarButtonItem()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let shareView = TitleContentView(title: "分享", contentView: ShareView())
    private let oauthView = TitleContentView(title: "登录", contentView: OauthView())
    private let launchView = TitleContentView(title: "启动", contentView: LaunchView())
}

extension PlatformViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupNavigationItem()
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

        launchView.pin
            .horizontally()
            .sizeToFit(.width)
            .below(of: oauthView)

        let minHeight = scrollView.bounds.size.height
            - scrollView.pin.safeArea.top
            - scrollView.pin.safeArea.bottom

        contentView.pin
            .wrapContent(.vertically)
            .minHeight(minHeight)

        scrollView.contentSize = contentView.bounds.size
    }

    private func setupNavigationItem() {
        navigationItem.rightBarButtonItem = handlerBarButtonItem
    }

    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(shareView)
        contentView.addSubview(oauthView)
        contentView.addSubview(launchView)
    }
}

extension PlatformViewController {

    func binding(_ viewModel: ViewModel) {
        self.viewModel = viewModel

        viewModel.title
            .bind(to: rx.title)
            .disposed(by: disposeBag)

        viewModel.isSwitchEnabled
            .bind(to: handlerBarButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.currentCategory
            .map { category in "\(category)" }
            .bind(to: handlerBarButtonItem.rx.title)
            .disposed(by: disposeBag)

        viewModel.currentHandler
            .bind(onNext: {
                Bus.shared.handlers = [$0]
            })
            .disposed(by: disposeBag)

        handlerBarButtonItem.rx
            .tap
            .withLatestFrom(viewModel.currentCategory)
            .map { category in category.toggled() }
            .bind(to: viewModel.currentCategory)
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

        launchView.contentView.binding(viewModel)
        launchView.contentView.onLaunch = { [weak self] program, platform in
            self?.launch(program: program, with: platform)
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

    private func launch(program: MiniProgramMessage, with platform: Platform) {
        Bus.shared.launch(program: program, with: platform) { [weak self] result in
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
}
