class Blink1 < Formula
  desc "Control blink(1) indicator light"
  homepage "https://blink1.thingm.com/"
  url "https://github.com/todbot/blink1/archive/v1.97.tar.gz"
  sha256 "974722b466249ee47ec27659b160d2e4fd0c2bc3732d009f180f8ffb53dc5d92"
  head "https://github.com/todbot/blink1.git"


  def install
    cd "commandline" do
      system "make"
      bin.install "blink1-tool"
      lib.install "libBlink1.dylib"
      include.install "blink1-lib.h"
    end
  end

  test do
    system bin/"blink1-tool", "--version"
  end
end
