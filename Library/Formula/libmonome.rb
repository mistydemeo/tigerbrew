class Libmonome < Formula
  desc "Interact with monome devices via C, Python, or FFI"
  homepage "http://illest.net/libmonome/"
  url "https://github.com/monome/libmonome/archive/1.2.tar.gz"
  sha256 "c4af0d1e029049e35e0afff148109f41f839afd7cbcd431a2632585e80c57190"

  head "https://github.com/monome/libmonome.git"


  depends_on "liblo"

  def install
    inreplace "wscript", "-Werror", ""
    system "./waf", "configure", "--prefix=#{prefix}"
    system "./waf build"
    system "./waf install"
  end
end
