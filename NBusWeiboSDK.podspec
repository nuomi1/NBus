Pod::Spec.new do |s|
  s.name = "NBusWeiboSDK"
  s.version = "3.3.2"
  s.summary = "NBusWeiboSDK is a remade module framework for Weibo SDK."

  s.homepage = "https://github.com/nuomi1/NBus"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "nuomi1" => "nuomi1@qq.com" }
  s.source = { :http => "https://ghcr.io/v2/nuomi1/nbus/nbusweibosdk/blobs/sha256:3e52118d1e8be177fd42d2560058d3c3a8dfc09545926e4abff33bc9821aef31",
               :flatten => false, :type => "tgz", :sha256 => "3e52118d1e8be177fd42d2560058d3c3a8dfc09545926e4abff33bc9821aef31",
               :headers => ["Authorization: Bearer QQ=="] }

  s.swift_version = "5.0"
  s.static_framework = true

  s.ios.deployment_target = "10.0"

  s.vendored_frameworks = ["NBusWeiboSDK.framework"]
  s.resources = ["NBusWeiboSDK.framework/Versions/#{s.version}/Resources/WeiboSDK.bundle"]

  s.pod_target_xcconfig = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64" }
  s.user_target_xcconfig = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64" }
end
