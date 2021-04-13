# NBus

[![CI Status](https://img.shields.io/github/workflow/status/nuomi1/NBus/Swift)](https://github.com/nuomi1/NBus)
[![Version](https://img.shields.io/cocoapods/v/NBus)](https://cocoapods.org/pods/NBus)
[![License](https://img.shields.io/cocoapods/l/NBus)](https://cocoapods.org/pods/NBus)
[![Platform](https://img.shields.io/cocoapods/p/NBus)](https://cocoapods.org/pods/NBus)

## Introduction

NBus is a sharing and signin library for Chinese Social Application, such as WeChat, QQ and Weibo.
NBus also supports system's sharing and Sign in with Apple.

## Feature

### Share

| Handler          | Text | Image | Audio | Video | WebPage | File | MiniProgram |
| ---------------- | :--: | :---: | :---: | :---: | :-----: | :--: | :---------: |
| QQHandler        |  ✔️  |  ✔️   |  ✔️   |  ✔️   |   ✔️    |  ✔️  |     ✔️      |
| QQSDKHandler     |  ✔️  |  ✔️   |  ✔️   |  ✔️   |   ✔️    |  ✔️  |     ✔️      |
| WechatHandler    |  ✔️  |  ✔️   |  ✔️   |  ✔️   |   ✔️    |  ✔️  |     ✔️      |
| WechatSDKHandler |  ✔️  |  ✔️   |  ✔️   |  ✔️   |   ✔️    |  ✔️  |     ✔️      |
| WeiboHandler     |  ✔️  |  ✔️   |  ✔️   |  ✔️   |   ✔️    |  ❌  |     ❌      |
| WeiboSDKHandler  |  ✔️  |  ✔️   |  ✔️   |  ✔️   |   ✔️    |  ❌  |     ❌      |
| SystemHandler    |  ✔️  |  ✔️   |  ✔️   |  ✔️   |   ✔️    |  ✔️  |     ❌      |

### Oauth

| Handler          | Oauth |
| ---------------- | :---: |
| QQHandler        |  ✔️   |
| QQSDKHandler     |  ✔️   |
| WechatHandler    |  ✔️   |
| WechatSDKHandler |  ✔️   |
| WeiboHandler     |  ✔️   |
| WeiboSDKHandler  |  ✔️   |
| SystemHandler    |  ✔️   |

### Launch

| Handler          | MiniProgram |
| ---------------- | :---------: |
| QQHandler        |     ✔️      |
| QQSDKHandler     |     ✔️      |
| WechatHandler    |     ✔️      |
| WechatSDKHandler |     ✔️      |
| WeiboHandler     |     ❌      |
| WeiboSDKHandler  |     ❌      |
| SystemHandler    |     ❌      |

> - ✔️ - Support
> - ⭕ - Experimental support
> - ❌ - NOT support

## Requirements

- Swift 5.0
- iOS 10.0
- [QQ 8.1.3 - 20190830](https://wiki.connect.qq.com/universal-links%E9%80%82%E9%85%8Dfaq)
- [Wechat 7.0.7 - 20190917](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/Access_Guide/iOS.html)
- [Weibo ~ 20201017](https://github.com/sinaweibosdk/weibo_ios_sdk)

## Usage

1. Edit `LSApplicationQueriesSchemes` in `Info.plist`.

```plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
    <string>mqq</string>
    <string>mqqopensdkapiV2</string>
    <string>mqqopensdklaunchminiapp</string>
    <string>mqqopensdkminiapp</string>
    <string>mqqopensdknopasteboard</string>
    <string>weixin</string>
    <string>weixinULAPI</string>
    <string>sinaweibo</string>
    <string>weibosdk</string>
    <string>weibosdk3.3</string>
</array>
</plist>
```

2. Edit `CFBundleURLTypes` in `Info.plist`.

```plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>QQ</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>tencent123456</string>
        </array>
    </dict>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>Wechat</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>wx123456</string>
        </array>
    </dict>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>Weibo</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>wb123456</string>
        </array>
    </dict>
</array>
</plist>
```

3. Edit `com.apple.developer.associated-domains` in `TARGET.entitlements`.

```plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
    <string>applinks:www.example.com</string>
</array>
</plist>
```

4. Register handler(s) before using NBus.

```swift
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    let qqHandler = QQHandler(
        appID: "tencent123456",
        universalLink: URL(string: "https://www.example.com/qq_conn/123456/")!
    )

    Bus.shared.handlers = [qqHandler]
}
```

```swift
func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
) -> Bool {
    Bus.shared.openURL(url)
}
```

```swift
func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
) -> Bool {
    Bus.shared.openUserActivity(userActivity)
}
```

5. Share message using NBus.

```swift
let message = Messages.text(text: "NBus")
let endpoint = Endpoints.QQ.friend

Bus.shared.share(message: message, to: endpoint) { result in
    switch result {
    case .success:
        print("Success")
    case let .failure(error):
        print(error)
    }
}
```

6. Oauth using NBus.

```swift
let platform = Platforms.qq

Bus.shared.oauth(with: platform) { result in
    switch result {
    case let .success(parameters):
        let accessToken = parameters[Bus.OauthInfoKeys.QQ.accessToken]
        let expirationDate = parameters[Bus.OauthInfoKeys.QQ.expirationDate]
        let openID = = parameters[Bus.OauthInfoKeys.QQ.openID]

        print(accessToken, expirationDate, openID)
    case let .failure(error):
        print(error)
    }
}
```

7. Launch Mini Program using NBus.

```swift
let program = Messages.miniProgram(
    miniProgramID: "123456",
    path: "/example",
    link: URL(string: "https://www.example")!,
    miniProgramType: .release,
    title: "NBus",
    description: "NBus",
    thumbnail: UIImage(named: "example")?.jpegData(compressionQuality: 1)
)

let platform = Platforms.qq

Bus.shared.launch(program: program, with: platform) { result in
    switch result {
    case .success:
        print("Success") // Never happen
    case let .failure(error):
        print(error)
    }
}
```

## Example

To run the example project, clone the repo, edit the `Example/NBus/Config.xcconfig` file, and run `bundle install && bundle exec fastlane setup && open Example/NBus.xcworkspace` from the Example directory first.

## Installation

### CocoaPods

You can use `NBus` directly which is including all SDK bridging handlers.

```ruby
pod "NBus" # default subspecs "SDKHandlers"
```

or all open source handlers.

```ruby
pod "NBus/BusHandlers"
```

or what you like.

```ruby
pod "NBus/QQSDKHandler"
pod "NBus/QQHandler"

pod "NBus/WechatSDKHandler"
pod "NBus/WechatHandler"

pod "NBus/WeiboSDKHandler"
pod "NBus/WeiboHandler"

pod "NBus/SystemHandler"
```

## WARNING

1. `WeiboSDK.bundle` must saved in App's root path.

## Author

nuomi1, [nuomi1@qq.com](mailto:nuomi1@qq.com)

## Related articles

- [NBus 的由来](https://blog.nuomi1.com/archives/2020/09/nbus-comes-from.html)
- [NBus 之 QQHandler](https://blog.nuomi1.com/archives/2021/01/nbus-qqhandler.html)
- [NBus 之 QQSDKHandler](https://blog.nuomi1.com/archives/2020/12/nbus-qqsdkhandler.html)
- [NBus 之 SystemHandler](https://blog.nuomi1.com/archives/2020/12/nbus-systemhandler.html)
- [NBus 之 WechatHandler](https://blog.nuomi1.com/archives/2021/01/nbus-wechathandler.html)
- [NBus 之 WechatSDKHandler](https://blog.nuomi1.com/archives/2020/12/nbus-wechatsdkhandler.html)
- [NBus 之 WeiboHandler](https://blog.nuomi1.com/archives/2021/01/nbus-weibohandler.html)
- [NBus 之 WeiboSDKHandler](https://blog.nuomi1.com/archives/2020/12/nbus-weibosdkhandler.html)

## Thanks

- [MonkeyKing](https://github.com/nixzhu/MonkeyKing)
- [LQThirdParty](https://github.com/LQi2009/LQThirdParty)

## License

NBus is available under the MIT license. See the LICENSE file for more info.
