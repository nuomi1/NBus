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

    // swiftlint:disable line_length

    static let text: MessageType = {
        // https://suulnnka.github.io/BullshitGenerator/?%E4%B8%BB%E9%A2%98=BUS&%E9%9A%8F%E6%9C%BA%E7%A7%8D%E5%AD%90=1038191506
        let text = "那么， 带着这些问题，我们来审视一下BUS。 可是，即使是这样，BUS的出现仍然代表了一定的意义。 BUS的发生，到底需要如何做到，不BUS的发生，又会如何产生。 生活中，若BUS出现了，我们就不得不考虑它出现了的事实。 经过上述讨论， 那么， 既然如何， 现在，解决BUS的问题，是非常非常重要的。 所以， 我们都知道，只要有意义，那么就必须慎重考虑。 这种事实对本人来说意义重大，相信对这个世界也是有一定意义的。 康德曾经提到过，既然我已经踏上这条道路，那么，任何东西都不应妨碍我沿着这条路走下去。这似乎解答了我的疑惑。"

        return Messages.text(text: text)
    }()

    // swiftlint:enable line_length

    static let image: MessageType = {
        // https://unsplash.com/photos/CEubYUySRo4
        let image = UIImage(named: "unsplash-CEubYUySRo4")!

        return Messages.image(data: image.jpegData(compressionQuality: 1)!)
    }()

    static let gif: MessageType = {
        // https://giphy.com/gifs/bus-J1ZajKJKzD0PK
        let dataAsset = NSDataAsset(name: "giphy-J1ZajKJKzD0PK")!
        let data = dataAsset.data
        let thumbnail = UIImage(data: data)?.jpegData(compressionQuality: 0.2)

        return Messages.image(
            data: data,
            thumbnail: thumbnail
        )
    }()

    static let audio: MessageType = {
        // https://music.163.com/#/song?id=25706284
        let url = URL(string: "https://music.163.com/#/song?id=25706284")!
        let dataURL = URL(string: "https://music.163.com/song/media/outer/url?id=25706284.mp3")!

        let title = "Chemical Bus"
        let description = "逃跑计划"

        return Messages.audio(
            link: url,
            dataLink: dataURL,
            title: title,
            description: description
        )
    }()

    static let video: MessageType = {
        // https://giphy.com/gifs/animation-dancing-cute-l0ExhgDYmserkFabm
        let url = URL(string: "https://giphy.com/gifs/animation-dancing-cute-l0ExhgDYmserkFabm")!

        let title = "Animation Dancing"
        let description = "Motiongarten"

        return Messages.video(
            link: url,
            title: title,
            description: description
        )
    }()

    static let webPage: MessageType = {
        // https://www.apple.com.cn/iphone/
        let url = URL(string: "https://www.apple.com.cn/iphone/")!

        let title = "iPhone"
        let description = "Apple"

        let dataAsset = NSDataAsset(name: "giphy-J1ZajKJKzD0PK")!
        let data = dataAsset.data
        let thumbnail = UIImage(data: data)?.jpegData(compressionQuality: 0.2)

        return Messages.webPage(
            link: url,
            title: title,
            description: description,
            thumbnail: thumbnail
        )
    }()

    static let file: MessageType = {
        // https://giphy.com/gifs/bus-J1ZajKJKzD0PK
        let dataAsset = NSDataAsset(name: "giphy-J1ZajKJKzD0PK")!
        let data = dataAsset.data

        let fileName = "J1ZajKJKzD0PK"

        return Messages.file(
            data: data,
            fileExtension: "gif",
            fileName: fileName
        )
    }()

    static let qqMiniProgram: MessageType = {
        let path = "/pages/component/pages/launchApp813/launchApp813?a=aaa&b=bbb&c=ccc"
        let url = URL(string: "https://www.apple.com.cn/iphone/")!

        let miniProgramID = AppState.getMiniProgramID(for: Platforms.qq)!

        return Messages.miniProgram(
            miniProgramID: miniProgramID,
            path: path,
            link: url,
            miniProgramType: .release
        )
    }()

    static let wechatMiniProgram: MessageType = {
        let path = "/pages/community/topics/id?id=565"
        let url = URL(string: "https://www.apple.com.cn/iphone/")!

        let miniProgramID = AppState.getMiniProgramID(for: Platforms.wechat)!

        return Messages.miniProgram(
            miniProgramID: miniProgramID,
            path: path,
            link: url,
            miniProgramType: .release
        )
    }()
}
