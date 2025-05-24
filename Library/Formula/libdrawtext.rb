class Libdrawtext < Formula
  desc "Library for anti-aliased text rendering in OpenGL"
  homepage "http://nuclear.mutantstargoat.com/sw/libdrawtext/"
  url "http://nuclear.mutantstargoat.com/sw/libdrawtext/libdrawtext-0.2.1.tar.gz"
  sha256 "d283d4393381388f3f6dc91c9c385fcc49361aa89acc368c32db69393ffdde21"
  head "https://github.com/jtsiomb/libdrawtext.git"
  revision 1


  depends_on "pkg-config" => :build
  depends_on "freetype"
  depends_on "glew"

  def install
    system "./configure", "--disable-dbg", "--enable-opt", "--prefix=#{prefix}"
    system "make", "install"
  end
end
