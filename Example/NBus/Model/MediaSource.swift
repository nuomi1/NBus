//
//  MediaSource.swift
//  BusMock
//
//  Created by nuomi1 on 2020/8/26.
//  Copyright © 2020 nuomi1. All rights reserved.
//

import NBus
import UIKit

enum MediaSource {

    static let text: MessageType = Messages.text(
        text: defaultText
    )

    static let image: MessageType = {
        let data = defaultJPEG.jpegData(compressionQuality: 1)!
        let thumbnail = defaultJPEG.jpegData(compressionQuality: 0.2)!

        return Messages.image(
            data: data,
            title: defaultTitle,
            description: defaultDescription,
            thumbnail: thumbnail
        )
    }()

    static let gif: MessageType = Messages.image(
        data: defaultGIF,
        title: defaultTitle,
        description: defaultDescription,
        thumbnail: defaultThumbnail
    )

    static let audio: MessageType = {
        let url = URL(string: "https://music.163.com/#/song?id=25706284")!
        let dataURL = URL(string: "https://music.163.com/song/media/outer/url?id=25706284.mp3")!

        let title = "Chemical Bus"
        let description = "逃跑计划"

        return Messages.audio(
            link: url,
            dataLink: dataURL,
            title: title,
            description: description,
            thumbnail: defaultThumbnail
        )
    }()

    static let video: MessageType = {
        let url = URL(string: "https://giphy.com/gifs/animation-dancing-cute-l0ExhgDYmserkFabm")!

        let title = "Animation Dancing"
        let description = "Motiongarten"

        return Messages.video(
            link: url,
            title: title,
            description: description,
            thumbnail: defaultThumbnail
        )
    }()

    static let webPage: MessageType = Messages.webPage(
        link: defaultLink,
        title: defaultTitle,
        description: defaultDescription,
        thumbnail: defaultThumbnail
    )

    static let file: MessageType = {
        let fileExtension = "gif"
        let fileName = "J1ZajKJKzD0PK"

        return Messages.file(
            data: defaultGIF,
            fileExtension: fileExtension,
            fileName: fileName,
            title: defaultTitle,
            description: defaultDescription,
            thumbnail: defaultThumbnail
        )
    }()

    static let qqMiniProgram: MessageType = {
        let miniProgramID = AppState.getMiniProgramID(for: Platforms.qq)!
        let path = "/pages/component/pages/launchApp813/launchApp813?a=aaa&b=bbb&c=ccc"

        return Messages.miniProgram(
            miniProgramID: miniProgramID,
            path: path,
            link: defaultLink,
            miniProgramType: .release,
            title: defaultTitle,
            description: defaultDescription,
            thumbnail: defaultThumbnail
        )
    }()

    static let wechatMiniProgram: MessageType = {
        let miniProgramID = AppState.getMiniProgramID(for: Platforms.wechat)!
        let path = "/pages/community/topics/id?id=565"

        return Messages.miniProgram(
            miniProgramID: miniProgramID,
            path: path,
            link: defaultLink,
            miniProgramType: .release,
            title: defaultTitle,
            description: defaultDescription,
            thumbnail: defaultThumbnail
        )
    }()
}

extension MediaSource {

    // swiftlint:disable line_length

    private static var defaultText: String {
        // https://suulnnka.github.io/BullshitGenerator/?%E4%B8%BB%E9%A2%98=BUS&%E9%9A%8F%E6%9C%BA%E7%A7%8D%E5%AD%90=1038191506
        let text = "那么， 带着这些问题，我们来审视一下BUS。 可是，即使是这样，BUS的出现仍然代表了一定的意义。 BUS的发生，到底需要如何做到，不BUS的发生，又会如何产生。 生活中，若BUS出现了，我们就不得不考虑它出现了的事实。 经过上述讨论， 那么， 既然如何， 现在，解决BUS的问题，是非常非常重要的。 所以， 我们都知道，只要有意义，那么就必须慎重考虑。 这种事实对本人来说意义重大，相信对这个世界也是有一定意义的。 康德曾经提到过，既然我已经踏上这条道路，那么，任何东西都不应妨碍我沿着这条路走下去。这似乎解答了我的疑惑。"

        return text
    }

    // swiftlint:enable line_length

    private static var defaultJPEG: UIImage {
        // https://unsplash.com/photos/CEubYUySRo4
        let image = UIImage(named: "unsplash-CEubYUySRo4")

        return image!
    }

    private static var defaultGIF: Data {
        // https://giphy.com/gifs/bus-J1ZajKJKzD0PK
        let dataAsset = NSDataAsset(name: "giphy-J1ZajKJKzD0PK")
        let data = dataAsset?.data

        return data!
    }

    private static var defaultLink: URL {
        let link = URL(string: "https://www.apple.com.cn/iphone/")

        return link!
    }

    private static var defaultTitle: String {
        let title = "iPhone"

        return title
    }

    private static var defaultDescription: String {
        let description = "Apple"

        return description
    }

    private static var defaultThumbnail: Data {
        let thumbnail = UIImage(data: defaultGIF)?.jpegData(compressionQuality: 0.2)

        return thumbnail!
    }
}
