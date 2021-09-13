Pod::Spec.new do |s|
  s.name = "NBusWeiboSDK"
  s.version = "3.3.1"
  s.summary = "NBusWeiboSDK is a remade module framework for Weibo SDK."

  s.homepage = "https://github.com/nuomi1/NBus"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "nuomi1" => "nuomi1@qq.com" }
  s.source = { :http => "https://ghcr.io/v2/nuomi1/nbus/nbusweibosdk/blobs/sha256:e2e0ab8148b3900e6c1463b1c10988dadfdd97a9db6f5c2eb20ba65471c4b3ae",
               :type => "tgz", :sha256 => "e2e0ab8148b3900e6c1463b1c10988dadfdd97a9db6f5c2eb20ba65471c4b3ae",
               :headers => ["Authorization: Bearer QQ=="] }

  s.swift_version = "5.0"
  s.static_framework = true

  s.ios.deployment_target = "10.0"

  s.vendored_frameworks = ["NBusWeiboSDK.framework"]
  s.resources = ["WeiboSDK.bundle"]
  s.preserve_paths = ["**/NBusWeiboSDK.framework", "**/WeiboSDK.bundle"]
end
