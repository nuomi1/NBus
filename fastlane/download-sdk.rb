require "Digest"
require "FileUtils"
require "Open3"
require "Pathname"
require "URI"

def download_sdk(category)
  root = (Pathname.pwd / "./NBus/Vendor").expand_path

  FileUtils.mkdir_p(root)

  case category
  when "qq"
    vendor = "QQ"
    vendor_package = "nbusqqsdk"
    vendor_sha256 = "77ccee516791e191b1edeab9fe3e20879d5022eebc0e2a5270fa6007b575699d"
  when "wechat"
    vendor = "Wechat"
    vendor_package = "nbuswechatsdk"
    vendor_sha256 = "418aef25e95950de4744ca17ddf6965235cb67ebd08fd8ba1bccae076bbe7285"
  when "weibo"
    vendor = "Weibo"
    vendor_package = "nbusweibosdk"
    vendor_sha256 = "6034a464f2eca3c5d01999c02a8bf68fa4998c1f61dcf0904980e49a5647d127"
  else
    raise("never")
  end

  owner = "nuomi1"
  repo = "nbus"

  url = URI("https://ghcr.io/v2/#{owner}/#{repo}/#{vendor_package}/blobs/sha256:#{vendor_sha256}")
  file = root / "#{vendor}SDK.tar.gz"
  sdk_directory = root / "#{vendor}SDK"

  download_github_package(url, file, vendor_sha256)
  extract_file(file, sdk_directory)
end

def download_github_package(url, file, sha256)
  if file.exist? && Digest::SHA256.file(file) == sha256
    puts("file exist")
  else
    sh(["wget", "--header", "'Authorization: Bearer QQ=='", url.to_s, "-O", file.to_s])
    if Digest::SHA256.file(file) == sha256
      puts("download success")
    else
      raise("download failure")
    end
  end
end

def extract_file(file, sdk_directory)
  FileUtils.rm_rf(sdk_directory)

  sh(["tar", "-x", "-C", sdk_directory.dirname.to_s, "-f", file.to_s, sdk_directory.basename.to_s])
end

def sh(*command)
  command = command.join(" ")

  result = ""
  exit_status = nil

  Open3.popen2e(command) do |stdin, io, thread|
    io.sync = true
    io.each do |line|
      result << line
    end
    exit_status = thread.value
  end
end

download_sdk(ARGV[0])
