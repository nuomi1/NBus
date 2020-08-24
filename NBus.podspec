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

  s.default_subspecs = "SDKHandlers"

  s.subspec "SDKHandlers" do |ss|
    ss.dependency "NBus/QQSDKHandler"
    ss.dependency "NBus/WechatSDKHandler"
    ss.dependency "NBus/WeiboSDKHandler"
    ss.dependency "NBus/SystemHandler"
  end

  s.subspec "Core" do |ss|
    ss.source_files = ["NBus/Classes/Core/**/*.swift"]
  end

  s.subspec "QQSDKHandler" do |ss|
    ss.dependency "NBus/Core"
    ss.dependency "NBus/QQSDK"

    ss.source_files = ["NBus/Classes/Handler/QQSDKHandler.swift"]
  end

  s.subspec "WechatSDKHandler" do |ss|
    ss.dependency "NBus/Core"
    ss.dependency "NBus/WechatSDK"

    ss.source_files = ["NBus/Classes/Handler/WechatSDKHandler.swift"]
  end

  s.subspec "WeiboSDKHandler" do |ss|
    ss.dependency "NBus/Core"
    ss.dependency "NBus/WeiboSDK"

    ss.source_files = ["NBus/Classes/Handler/WeiboSDKHandler.swift"]
  end

  s.subspec "SystemHandler" do |ss|
    ss.dependency "NBus/Core"

    ss.source_files = ["NBus/Classes/Handler/SystemHandler.swift"]
  end

  s.subspec "QQSDK" do |ss|
    ss.vendored_frameworks = ["NBus/Vendor/QQ_SDK/**/*.framework"]
    ss.frameworks = ["SystemConfiguration", "WebKit"]

    ss.source_files = ["NBus/Vendor/QQ_SDK/**/*.h"]
  end

  s.subspec "WechatSDK" do |ss|
    ss.vendored_libraries = ["NBus/Vendor/Wechat_SDK/**/*.a"]
    ss.frameworks = ["WebKit"]
    ss.libraries = ["c++"]

    ss.source_files = ["NBus/Vendor/Wechat_SDK/**/*.h"]

    ss.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC -all_load" }
  end

  s.subspec "WeiboSDK" do |ss|
    ss.vendored_libraries = ["NBus/Vendor/Weibo_SDK/**/*.a"]

    ss.source_files = ["NBus/Vendor/Weibo_SDK/**/*.h"]

    ss.resources = ["NBus/Vendor/Weibo_SDK/**/*.bundle"]
  end

  s.prepare_command = <<-CMD
    function download_sdk() {
      local VENDOR=$1
      local VENDOR_VER=$2
      local VENDOR_URL=$3
      local VENDOR_SHA1=$4
      local VENDOR_FILE="Vender_${VENDOR}_${VENDOR_VER}.zip"
      local VENDOR_SEARCH=$5
      local VENDOR_ZIP_DIR="${VENDOR}_ZIP"
      local VENDOR_SDK_DIR="${VENDOR}_SDK"

      rm -rf ${VENDOR_ZIP_DIR} ${VENDOR_SDK_DIR}
      mkdir ${VENDOR_SDK_DIR}

      if [ ! -f ${VENDOR_FILE} ]; then
        wget -c ${VENDOR_URL} -O ${VENDOR_FILE}
      fi

      ditto -V -x -k --sequesterRsrc --rsrc ${VENDOR_FILE} ${VENDOR_ZIP_DIR}

      for file in $(find -E ${VENDOR_ZIP_DIR}/${VENDOR_SEARCH} -d 1 -regex ".*/*.(bundle|framework|a|h)"); do
        cp -r ${file} ${VENDOR_SDK_DIR}
      done
    }

    cd NBus

    mkdir -p Vendor
    cd Vendor

    QQ="QQ"
    QQ_VER="3.3.9"
    QQ_URL="http://d3g.qq.com/qzone/Publish-Sdk${QQ_VER}-Lite.zip"
    QQ_SHA1="edac517333ba92aef666afb8c7fd00e458f37629"
    QQ_SEARCH="Publish-Sdk${QQ_VER}-Lite/sdk-Lite"
    download_sdk ${QQ} ${QQ_VER} ${QQ_URL} ${QQ_SHA1} ${QQ_SEARCH}

    WECHAT="Wechat"
    WECHAT_VER="1.8.7.1"
    WECHAT_URL="https://res.wx.qq.com/op_res/DHI055JVxYur-5c7ss5McQZj2Y9KZQlp24xwD7FYnF88x8LA8rWCzSfdStN5tiCD"
    WECHAT_SHA1="5359ec0b4fc707f41fcf458fe4faebb83efd4011"
    WECHAT_SEARCH="OpenSDK${WECHAT_VER}"
    download_sdk ${WECHAT} ${WECHAT_VER} ${WECHAT_URL} ${WECHAT_SHA1} ${WECHAT_SEARCH}

    WEIBO="Weibo"
    WEIBO_VER="3.2.7"
    WEIBO_URL="https://github.com/sinaweibosdk/weibo_ios_sdk/archive/${WEIBO_VER}.zip"
    WEIBO_SHA1="4143bb25b3ac6e865aff281e8d6638e11bc3bebf"
    WEIBO_SEARCH="weibo_ios_sdk-${WEIBO_VER}/libWeiboSDK"
    download_sdk ${WEIBO} ${WEIBO_VER} ${WEIBO_URL} ${WEIBO_SHA1} ${WEIBO_SEARCH}
  CMD
end
