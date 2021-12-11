Pod::Spec.new do |s|
  s.name = "NBusWechatSDK"
  s.version = "1.9.2+revision1"
  s.summary = "NBusWechatSDK is a remade module framework for WeChat SDK."

  s.homepage = "https://github.com/nuomi1/NBus"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "nuomi1" => "nuomi1@qq.com" }
  s.source = { :http => "https://ghcr.io/v2/nuomi1/nbus/nbuswechatsdk/blobs/sha256:3ea28f9e2e52cc3774d13e10376d55c7a2132998b26290ec7c482d77ac5f4635",
               :flatten => false, :type => "tgz", :sha256 => "3ea28f9e2e52cc3774d13e10376d55c7a2132998b26290ec7c482d77ac5f4635",
               :headers => ["Authorization: Bearer QQ=="] }

  s.swift_version = "5.0"
  s.static_framework = true

  s.ios.deployment_target = "10.0"

  s.frameworks = ["CoreGraphics", "UIKit", "WebKit"]
  s.libraries = ["c++"]

  s.vendored_frameworks = ["NBusWechatSDK.framework"]

  s.pod_target_xcconfig = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64" }
  s.user_target_xcconfig = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64" }
end
