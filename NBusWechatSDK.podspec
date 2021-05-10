Pod::Spec.new do |s|
  s.name = "NBusWechatSDK"
  s.version = "1.2.0"
  s.summary = "A short description of NBusWechatSDK."

  s.homepage = "https://github.com/nuomi1/NBus"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "nuomi1" => "nuomi1@qq.com" }
  s.source = { :git => "https://github.com/nuomi1/NBus.git", :tag => s.version }

  s.ios.deployment_target = "10.0"

  s.swift_version = "5.0"

  s.vendored_libraries = ["NBus/Vendor/WechatSDK/**/*.a"]
  s.frameworks = ["WebKit"]
  s.libraries = ["c++"]

  s.source_files = ["NBus/Vendor/WechatSDK/**/ReplaceMe.swift", "NBus/Vendor/WechatSDK/**/*.h"]

  s.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC -all_load" }

  s.prepare_command = "ruby fastlane/download-sdk.rb wechat"
end
