Pod::Spec.new do |s|
  s.name = "NBusQQSDK"
  s.version = "1.1.0"
  s.summary = "A short description of NBusQQSDK."

  s.homepage = "https://github.com/nuomi1/NBus"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "nuomi1" => "nuomi1@qq.com" }
  s.source = { :git => "https://github.com/nuomi1/NBus.git", :tag => s.version }

  s.ios.deployment_target = "10.0"

  s.swift_version = "5.0"

  s.vendored_frameworks = ["NBus/Vendor/QQSDK/**/*.framework"]
  s.frameworks = ["SystemConfiguration", "WebKit"]

  s.source_files = ["NBus/Vendor/QQSDK/**/ReplaceMe.swift", "NBus/Vendor/QQSDK/**/*.h"]

  s.resources = ["NBus/Vendor/QQSDK/**/*.bundle"]

  s.prepare_command = "ruby fastlane/download-sdk.rb qq"
end
