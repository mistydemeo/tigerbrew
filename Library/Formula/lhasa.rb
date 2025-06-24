class Lhasa < Formula
  desc "LHA implementation to decompress .lzh and .lzs archives"
  homepage "https://fragglet.github.io/lhasa/"
  url "https://github.com/fragglet/lhasa/archive/v0.3.0.tar.gz"
  sha256 "b9baae6508e6028a0cb871be7e4669be508542644382794d88d44744b9efdbe0"
  head "https://github.com/fragglet/lhasa.git"


  conflicts_with "lha", :because => "both install a `lha` binary"

  depends_on "pkg-config" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    system "./autogen.sh", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    str = "MQAtbGgwLQQAAAAEAAAA9ZQTUyACg2JVBQAA" \
          "hloGAAFmb28FAFCkgQcAURQA9QEAAGZvbwoA"
    system "echo #{str} | /usr/bin/base64 -D | #{bin}/lha x -"
    assert_equal "foo\n", `cat foo`
  end
end
