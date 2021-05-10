//
//  PlatformViewController+Share.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import NBus
import RxSwift
import UIKit

extension PlatformViewController {

    class ShareView: UIView {

        typealias Constant = PlatformViewController.Constant
        typealias ViewModel = PlatformViewController.ViewModel

        var onShare: (MessageType, Endpoint, UIView) -> Void = { _, _, _ in }

        private var viewModel: ViewModel?

        private let disposeBag = DisposeBag()

        private let textButton = UIButton(type: Constant.buttonType)
        private let imageButton = UIButton(type: Constant.buttonType)
        private let gifButton = UIButton(type: Constant.buttonType)
        private let audioButton = UIButton(type: Constant.buttonType)
        private let videoButton = UIButton(type: Constant.buttonType)
        private let webPageButton = UIButton(type: Constant.buttonType)
        private let fileButton = UIButton(type: Constant.buttonType)
        private let miniProgramButton = UIButton(type: Constant.buttonType)

        private let segmentedControl = UISegmentedControl()

        private var allButtons: [UIButton] {
            return [
                textButton,
                imageButton,
                gifButton,
                audioButton,
                videoButton,
                webPageButton,
                fileButton,
                miniProgramButton,
            ]
        }

        private var allSubviews: [UIView] {
            return allButtons + [segmentedControl]
        }

        private var allActions: [() -> Void] {
            return [
                didTapTextButton,
                didTapImageButton,
                didTapGifButton,
                didTapAudioButton,
                didTapVideoButton,
                didTapWebPageButton,
                didTapFileButton,
                didTapMiniProgramButton,
            ]
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

extension PlatformViewController.ShareView {

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
        var edge = self.edge.top

        allSubviews.forEach { subview in
            let size = CGSize(
                width: subview.intrinsicContentSize.width * Constant.widthMultiple,
                height: subview.intrinsicContentSize.height
            )

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
        zip(allButtons, Message.allCases).forEach { button, messageType in
            button.setTitle("\(messageType)", for: .normal)
            setupBorder(button)
        }

        allSubviews.forEach(addSubview)
    }

    private func setupBinding() {
        zip(allButtons, allActions).forEach { button, action in
            button.rx
                .tap
                .bind(onNext: action)
                .disposed(by: disposeBag)
        }
    }

    private func setupBorder(_ view: UIView) {
        view.layer.borderColor = Constant.borderColor
        view.layer.borderWidth = Constant.borderWidth
        view.layer.cornerRadius = Constant.cornerRadius
    }
}

extension PlatformViewController.ShareView {

    func binding(_ viewModel: ViewModel) {
        self.viewModel = viewModel

        allButtons.forEach { button in
            viewModel.isShareEnabled
                .bind(to: button.rx.isEnabled)
                .disposed(by: disposeBag)
        }

        viewModel.endpoints
            .bind(onNext: updateSegmentedControl)
            .disposed(by: disposeBag)

        segmentedControl.rx
            .selectedSegmentIndex
            .withLatestFrom(viewModel.endpoints) { index, endpoints -> Endpoint? in
                endpoints[safe: index]
            }
            .bind(to: viewModel.currentEndpoint)
            .disposed(by: disposeBag)
    }

    private func updateSegmentedControl(endpoints: [Endpoint]) {
        segmentedControl.removeAllSegments()

        endpoints.enumerated().forEach { index, endpoint in
            segmentedControl.insertSegment(withTitle: "\(endpoint)", at: index, animated: false)
        }

        segmentedControl.selectedSegmentIndex = !endpoints.isEmpty
            ? endpoints.indices.lowerBound
            : UISegmentedControl.noSegment
    }
}

extension PlatformViewController.ShareView {

    private func didTapTextButton() {
        share(MediaSource.text, in: textButton)
    }

    private func didTapImageButton() {
        share(MediaSource.image, in: imageButton)
    }

    private func didTapGifButton() {
        share(MediaSource.gif, in: gifButton)
    }

    private func didTapAudioButton() {
        share(MediaSource.audio, in: audioButton)
    }

    private func didTapVideoButton() {
        share(MediaSource.video, in: videoButton)
    }

    private func didTapWebPageButton() {
        share(MediaSource.webPage, in: webPageButton)
    }

    private func didTapFileButton() {
        share(MediaSource.file, in: fileButton)
    }

    private func didTapMiniProgramButton() {
        let message: MessageType

        switch viewModel?.platform.value {
        case Platforms.wechat:
            message = MediaSource.wechatMiniProgram
        case Platforms.qq:
            message = MediaSource.qqMiniProgram
        default:
            message = MediaSource.wechatMiniProgram
        }

        share(message, in: miniProgramButton)
    }
}

extension PlatformViewController.ShareView {

    private func share(_ message: MessageType, in view: UIView) {
        guard
            let endpoint = viewModel?.currentEndpoint.value
        else { assertionFailure(); return }

        onShare(message, endpoint, view)
    }
}

extension Array {

    fileprivate subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
