class Nkf < Formula
  desc "Network Kanji code conversion Filter (NKF)"
  homepage "https://osdn.jp/projects/nkf/"
  url "http://dl.osdn.jp/nkf/59912/nkf-2.1.3.tar.gz"
  sha256 "8cb430ae69a1ad58b522eb4927b337b5b420bbaeb69df255919019dc64b72fc2"


  def install
    inreplace "Makefile", "$(prefix)/man", "$(prefix)/share/man"
    system "make", "CC=#{ENV.cc}"
    # Have to specify mkdir -p here since the intermediate directories
    # don't exist in an empty prefix
    system "make", "install", "prefix=#{prefix}", "MKDIR=mkdir -p"
  end
end
