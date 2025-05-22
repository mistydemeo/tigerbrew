class Boxes < Formula
  desc "Draw boxes around text"
  homepage "http://boxes.thomasjensen.com/"
  url "https://github.com/ascii-boxes/boxes/archive/v1.1.2.tar.gz"
  head "https://github.com/ascii-boxes/boxes.git"
  sha256 "4d5e536be91b476ee48640bef9122f3114b16fe2da9b9906947308b94682c5fe"


  def install
    ENV.m32

    # distro uses /usr/share/boxes change to prefix
    system "make",
      "GLOBALCONF=#{share}/boxes-config",
      "CC=#{ENV.cc}",
      # Force 32 bit compile
      "CFLAGS_ADDTL=-m32",
      "LDFLAGS_ADDTL=-m32"

    bin.install "src/boxes"
    man1.install "doc/boxes.1"
    share.install "boxes-config"
  end

  test do
    assert_match "/* test brew */", pipe_output("#{bin}/boxes", "test brew")
  end
end
