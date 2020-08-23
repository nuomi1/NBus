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
  end

  s.subspec "Core" do |ss|
    ss.source_files = ["NBus/Classes/Core/**/*.swift"]
  end

  s.subspec "QQSDKHandler" do |ss|
    ss.dependency "NBus/Core"
    ss.dependency "NBus/QQSDK"

    ss.source_files = ["NBus/Classes/Handler/QQSDKHandler.swift"]
  end

  s.subspec "QQSDK" do |ss|
    ss.vendored_frameworks = ["NBus/Vendor/QQ_SDK/**/*.framework"]

    ss.source_files = ["NBus/Vendor/QQ_SDK/**/*.h"]
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
  CMD
end
