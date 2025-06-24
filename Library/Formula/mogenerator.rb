class Mogenerator < Formula
  desc "Generate Objective-C code for Core Data custom classes"
  homepage "https://rentzsch.github.io/mogenerator/"
  url "https://github.com/rentzsch/mogenerator/archive/1.29.tar.gz"
  sha256 "586bb71d647c64db62180e29ba6c5020b103418103ae2fed9481534e2bfec434"

  head "https://github.com/rentzsch/mogenerator.git"


  depends_on :xcode => :build

  def install
    xcodebuild "-target", "mogenerator", "-configuration", "Release", "SYMROOT=symroot", "OBJROOT=objroot"
    bin.install "symroot/Release/mogenerator"
  end
end
