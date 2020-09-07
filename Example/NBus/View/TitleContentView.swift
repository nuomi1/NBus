//
//  TitleContentView.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import UIKit

class TitleContentView<ContentView: UIView>: UIView {

    enum Constant {

        static var spacing: CGFloat { PlatformViewController.Constant.spacing }

        static var font: UIFont { UIFont.preferredFont(forTextStyle: .title2) }
    }

    private let titleLabel = UILabel()
    let contentView: ContentView

    init(title: String, contentView: ContentView) {
        titleLabel.text = title
        self.contentView = contentView
        super.init(frame: .zero)

        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        reLayout()

        pin
            .width(size.width)
            .wrapContent(.vertically)

        return bounds.size
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        reLayout()
    }

    private func reLayout() {
        titleLabel.pin
            .top()
            .horizontally(Constant.spacing)
            .height(2 * Constant.spacing)

        contentView.pin
            .top(to: titleLabel.edge.bottom)
            .horizontally()
            .sizeToFit(.width)
    }

    private func setupSubviews() {
        titleLabel.font = Constant.font

        [titleLabel, contentView]
            .forEach(addSubview)
    }
}
