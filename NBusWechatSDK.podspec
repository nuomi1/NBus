Pod::Spec.new do |s|
  s.name = "NBusWechatSDK"
  s.version = "1.9.2"
  s.summary = "NBusWechatSDK is a remade module framework for WeChat SDK."

  s.homepage = "https://github.com/nuomi1/NBus"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "nuomi1" => "nuomi1@qq.com" }
  s.source = { :http => "https://ghcr.io/v2/nuomi1/nbus/nbuswechatsdk/blobs/sha256:1a2758df5f2aafeeeb67b4f0357be05caa79a1d2982654dc26ab201179e38e33",
               :type => "tgz", :sha256 => "1a2758df5f2aafeeeb67b4f0357be05caa79a1d2982654dc26ab201179e38e33",
               :headers => ["Authorization: Bearer QQ=="] }

  s.swift_version = "5.0"
  s.static_framework = true

  s.ios.deployment_target = "10.0"

  s.frameworks = ["CoreGraphics", "UIKit", "WebKit"]
  s.libraries = ["c++"]

  s.vendored_frameworks = ["NBusWechatSDK.framework"]
  s.preserve_paths = ["**/NBusWechatSDK.framework"]
end
