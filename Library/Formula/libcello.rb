class Libcello < Formula
  desc "Higher-level programming in C"
  homepage "http://libcello.org/"
  head "https://github.com/orangeduck/libCello.git"
  url "http://libcello.org/static/libCello-1.1.7.tar.gz"
  sha256 "2273fe8257109c2dd19054beecd83ddcc780ec565a1ad02721e24efa74082908"


  def install
    system "make", "check"
    system "make", "install", "PREFIX=#{prefix}"
  end
end
