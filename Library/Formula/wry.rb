class Wry < Formula
  desc "Command-line App.net tool"
  homepage "http://grailbox.com/wry/"
  url "https://github.com/hoop33/wry/archive/v1.8.2.tar.gz"
  sha256 "bfc277b5425176c632716def46d8c8b6c8257eb764cf4cbd231de6f55c62c5f2"

  head "https://github.com/hoop33/wry.git"


  depends_on :macos => :lion
  depends_on :xcode => :build

  def install
    xcodebuild "-target", "wry", "-configuration", "Release", "SYMROOT=build", "OBJROOT=objroot"
    bin.install "build/Release/wry"
  end
end
