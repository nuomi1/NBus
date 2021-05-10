Pod::Spec.new do |s|
  s.name = "NBus"
  s.version = "1.2.0"
  s.summary = "A short description of NBus."

  s.homepage = "https://github.com/nuomi1/NBus"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "nuomi1" => "nuomi1@qq.com" }
  s.source = { :git => "https://github.com/nuomi1/NBus.git", :tag => s.version }

  s.ios.deployment_target = "10.0"

  s.swift_version = "5.0"

  s.default_subspecs = "SDKHandlers"

  s.subspec "BusHandlers" do |ss|
    ss.dependency "NBus/QQHandler"
    ss.dependency "NBus/WechatHandler"
    ss.dependency "NBus/WeiboHandler"
    ss.dependency "NBus/SystemHandler"
  end

  s.subspec "SDKHandlers" do |ss|
    ss.dependency "NBus/QQSDKHandler"
    ss.dependency "NBus/WechatSDKHandler"
    ss.dependency "NBus/WeiboSDKHandler"
    ss.dependency "NBus/SystemHandler"
  end

  s.subspec "Core" do |ss|
    ss.source_files = ["NBus/Classes/Core/**/*.swift"]
  end

  s.subspec "QQSDKHandler" do |ss|
    ss.dependency "NBus/Core"
    ss.dependency "NBusQQSDK"

    ss.source_files = ["NBus/Classes/Handler/QQSDKHandler.swift"]
  end

  s.subspec "QQHandler" do |ss|
    ss.dependency "NBus/Core"

    ss.source_files = ["NBus/Classes/Handler/QQHandler.swift"]
  end

  s.subspec "WechatSDKHandler" do |ss|
    ss.dependency "NBus/Core"
    ss.dependency "NBusWechatSDK"

    ss.source_files = ["NBus/Classes/Handler/WechatSDKHandler.swift"]
  end

  s.subspec "WechatHandler" do |ss|
    ss.dependency "NBus/Core"

    ss.source_files = ["NBus/Classes/Handler/WechatHandler.swift"]
  end

  s.subspec "WeiboSDKHandler" do |ss|
    ss.dependency "NBus/Core"
    ss.dependency "NBusWeiboSDK"

    ss.source_files = ["NBus/Classes/Handler/WeiboSDKHandler.swift"]
  end

  s.subspec "WeiboHandler" do |ss|
    ss.dependency "NBus/Core"

    ss.source_files = ["NBus/Classes/Handler/WeiboHandler.swift"]
  end

  s.subspec "SystemHandler" do |ss|
    ss.dependency "NBus/Core"

    ss.source_files = ["NBus/Classes/Handler/SystemHandler.swift"]
  end
end
