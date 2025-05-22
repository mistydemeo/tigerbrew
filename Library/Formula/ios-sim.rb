class IosSim < Formula
  desc "Command-line application launcher for the iOS Simulator"
  homepage "https://github.com/phonegap/ios-sim"
  url "https://github.com/phonegap/ios-sim/archive/3.1.1.tar.gz"
  sha256 "559e18f198d4c5298666fee8face0ac8d8dbce034d2c5241093bdd1d43014cb7"
  head "https://github.com/phonegap/ios-sim.git"


  depends_on :macos => :mountain_lion

  def install
    rake "install", "prefix=#{prefix}"
  end
end
