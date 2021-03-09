//
//  PlatformViewController+Launch.swift
//  BusMock
//
//  Created by nuomi1 on 2021/3/9.
//  Copyright © 2021 nuomi1. All rights reserved.
//

import NBus
import RxSwift
import UIKit

extension PlatformViewController {

    class LaunchView: UIView {

        typealias Constant = PlatformViewController.Constant
        typealias ViewModel = PlatformViewController.ViewModel

        var onLaunch: (MiniProgramMessage, Platform) -> Void = { _, _ in }

        private var viewModel: ViewModel?

        private let disposeBag = DisposeBag()

        private let launchButton = UIButton(type: Constant.buttonType)

        private var allButtons: [UIButton] {
            return [launchButton]
        }

        private var allSubviews: [UIView] {
            return allButtons
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

extension PlatformViewController.LaunchView {

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
        launchButton.setTitle("\(Messages.miniProgram)", for: .normal)
        setupBorder(launchButton)

        allSubviews.forEach(addSubview)
    }

    private func setupBinding() {
        launchButton.rx
            .tap
            .bind(onNext: didTapLaunchButton)
            .disposed(by: disposeBag)
    }

    private func setupBorder(_ view: UIView) {
        view.layer.borderColor = Constant.borderColor
        view.layer.borderWidth = Constant.borderWidth
        view.layer.cornerRadius = Constant.cornerRadius
    }
}

extension PlatformViewController.LaunchView {

    func binding(_ viewModel: ViewModel) {
        self.viewModel = viewModel

        viewModel.isLaunchEnabled
            .bind(to: launchButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

extension PlatformViewController.LaunchView {

    private func didTapLaunchButton() {
        guard
            let platform = viewModel?.platform.value
        else { assertionFailure(); return }

        let message: MessageType

        switch platform {
        case Platforms.wechat:
            message = MediaSource.wechatMiniProgram
        case Platforms.qq:
            message = MediaSource.qqMiniProgram
        default:
            message = MediaSource.wechatMiniProgram
        }

        let program = message as! MiniProgramMessage

        launch(program: program, with: platform)
    }
}

extension PlatformViewController.LaunchView {

    private func launch(program: MiniProgramMessage, with platform: Platform) {
        onLaunch(program, platform)
    }
}
