Pod::Spec.new do |s|
  s.name = "NBus"
  s.version = "0.1.0"
  s.summary = "A short description of NBus."

  s.homepage = "https://github.com/nuomi1/NBus"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "nuomi1" => "nuomi1@qq.com" }
  s.source = { :git => "https://github.com/nuomi1/NBus.git", :tag => s.version }

  s.ios.deployment_target = "10.0"

  s.swift_version = "5.0"

  s.source_files = "NBus/Classes/**/*.swift"
end
