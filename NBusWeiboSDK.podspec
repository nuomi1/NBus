Pod::Spec.new do |s|
  s.name = "NBusWeiboSDK"
  s.version = "1.1.0"
  s.summary = "A short description of NBusWeiboSDK."

  s.homepage = "https://github.com/nuomi1/NBus"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "nuomi1" => "nuomi1@qq.com" }
  s.source = { :git => "https://github.com/nuomi1/NBus.git", :tag => s.version }

  s.ios.deployment_target = "10.0"

  s.swift_version = "5.0"

  s.vendored_libraries = ["NBus/Vendor/WeiboSDK/**/*.a"]

  s.source_files = ["NBus/Vendor/WeiboSDK/**/ReplaceMe.swift", "NBus/Vendor/WeiboSDK/**/*.h"]

  s.resources = ["NBus/Vendor/WeiboSDK/**/*.bundle"]

  s.prepare_command = "ruby fastlane/download-sdk.rb weibo"
end
