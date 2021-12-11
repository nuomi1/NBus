Pod::Spec.new do |s|
  s.name = "NBusQQSDK"
  s.version = "3.5.7"
  s.summary = "NBusQQSDK is a remade module framework for QQ SDK."

  s.homepage = "https://github.com/nuomi1/NBus"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "nuomi1" => "nuomi1@qq.com" }
  s.source = { :http => "https://ghcr.io/v2/nuomi1/nbus/nbusqqsdk/blobs/sha256:3a4a37610be30c8bdc15441ffd5b90183d1cff1a6cfd681ef9040f14b3d6a5f7",
               :flatten => false, :type => "tgz", :sha256 => "3a4a37610be30c8bdc15441ffd5b90183d1cff1a6cfd681ef9040f14b3d6a5f7",
               :headers => ["Authorization: Bearer QQ=="] }

  s.swift_version = "5.0"
  s.static_framework = true

  s.ios.deployment_target = "10.0"

  s.frameworks = ["CoreGraphics", "SystemConfiguration", "UIKit", "WebKit"]

  s.vendored_frameworks = ["NBusQQSDK.framework"]
  s.resources = ["NBusQQSDK.framework/Versions/#{s.version}/Resources/TencentOpenApi_IOS_Bundle.bundle"]

  s.pod_target_xcconfig = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64" }
  s.user_target_xcconfig = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64" }
end
