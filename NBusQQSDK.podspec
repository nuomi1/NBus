Pod::Spec.new do |s|
  s.name = "NBusQQSDK"
  s.version = "3.5.5"
  s.summary = "NBusQQSDK is a remade module framework for QQ SDK."

  s.homepage = "https://github.com/nuomi1/NBus"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "nuomi1" => "nuomi1@qq.com" }
  s.source = { :http => "https://ghcr.io/v2/nuomi1/nbus/nbusqqsdk/blobs/sha256:f791fba718db624973d19ac57690b40f45ff4582abb2e8d41b322ceec91070bb",
               :type => "tgz", :sha256 => "f791fba718db624973d19ac57690b40f45ff4582abb2e8d41b322ceec91070bb",
               :headers => ["Authorization: Bearer QQ=="] }

  s.swift_version = "5.0"
  s.static_framework = true

  s.ios.deployment_target = "10.0"

  s.frameworks = ["CoreGraphics", "SystemConfiguration", "UIKit", "WebKit"]

  s.vendored_frameworks = ["NBusQQSDK.framework"]
  s.resources = ["TencentOpenApi_IOS_Bundle.bundle"]
  s.preserve_paths = ["**/NBusQQSDK.framework", "**/TencentOpenApi_IOS_Bundle.bundle"]
end
