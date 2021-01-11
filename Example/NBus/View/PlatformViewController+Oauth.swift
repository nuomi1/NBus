//
//  PlatformViewController+Oauth.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import NBus
import RxSwift
import UIKit

extension PlatformViewController {

    class OauthView: UIView {

        typealias Constant = PlatformViewController.Constant
        typealias ViewModel = PlatformViewController.ViewModel

        var onOauth: (Platform) -> Void = { _ in }

        private var viewModel: ViewModel?

        private let disposeBag = DisposeBag()

        private let oauthButton = UIButton(type: Constant.buttonType)

        private let infoTextView = UITextView()

        private var allButtons: [UIButton] {
            return [oauthButton]
        }

        private var allSubviews: [UIView] {
            return allButtons + [infoTextView]
        }

        override init(frame: CGRect) {
            super.init(frame: frame)

            setupSubviews()
            setupBinding()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension PlatformViewController.OauthView {

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        reLayout()

        let padding = UIEdgeInsets(
            top: Constant.spacing,
            left: 0,
            bottom: Constant.spacing,
            right: 0
        )

        pin
            .width(size.width)
            .wrapContent(.vertically, padding: padding)

        return bounds.size
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        reLayout()
    }

    private func reLayout() {
        guard
            let superview = superview
        else { assertionFailure(); return }

        var edge = self.edge.top

        allSubviews.forEach { subview in
            let size: CGSize = {
                (allButtons as [UIView]).contains(subview)
                    ? CGSize(
                        width: subview.intrinsicContentSize.width * Constant.widthMultiple,
                        height: subview.intrinsicContentSize.height
                    )
                    : CGSize(
                        width: max(0, superview.bounds.size.width - 2 * Constant.spacing),
                        height: 5 * Constant.spacing
                    )
            }()

            subview.pin
                .size(size)
                .hCenter()

            let marginTop = (allButtons as [UIView]).contains(subview)
                ? Constant.spacing
                : 2 * Constant.spacing

            subview.pin
                .top(to: edge)
                .marginTop(marginTop)

            edge = subview.edge.bottom
        }
    }

    private func setupSubviews() {
        allSubviews.forEach(setupBorder)

        infoTextView.isEditable = false

        allSubviews.forEach(addSubview)
    }

    private func setupBinding() {
        oauthButton.rx
            .tap
            .bind(onNext: didTapOauthButton)
            .disposed(by: disposeBag)
    }

    private func setupBorder(_ view: UIView) {
        view.layer.borderColor = Constant.borderColor
        view.layer.borderWidth = Constant.borderWidth
        view.layer.cornerRadius = Constant.cornerRadius
    }
}

extension PlatformViewController.OauthView {

    func binding(_ viewModel: ViewModel) {
        self.viewModel = viewModel

        viewModel.isOauthEnabled
            .bind(to: oauthButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.oauthInfo
            .map { $0.isLogin }
            .map { $0 ? "登出" : "登录" }
            .bind(to: oauthButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        viewModel.oauthInfo
            .map { $0.parameter }
            .bind(to: infoTextView.rx.text)
            .disposed(by: disposeBag)
    }
}

extension PlatformViewController.OauthView {

    private func didTapOauthButton() {
        oauth()
    }
}

extension PlatformViewController.OauthView {

    private func oauth() {
        guard
            let platform = viewModel?.platform.value
        else { assertionFailure(); return }

        onOauth(platform)
    }
}
