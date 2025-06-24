class Aha < Formula
  desc "ANSI HTML adapter"
  homepage "https://github.com/theZiz/aha"
  url "https://github.com/theZiz/aha/archive/0.4.8.tar.gz"
  sha256 "a1ebbbd5ebc37ccca74dc5f894e3066157e9e77fcdf158bf5587215b8968049c"

  head "https://github.com/theZiz/aha.git"


  def install
    # install manpages under share/man/
    inreplace "Makefile", "$(PREFIX)/man", "$(PREFIX)/share/man"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    out = pipe_output(bin/"aha", "[35mrain[34mpill[00m")
    assert_match(/color:purple;">rain.*color:blue;">pill/, out)
  end
end
