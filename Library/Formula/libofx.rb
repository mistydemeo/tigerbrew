class Libofx < Formula
  desc "Library to support OFX command responses"
  homepage "https://libofx.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/libofx/libofx/0.9.9/libofx-0.9.9.tar.gz"
  sha256 "94ef88c5cdc3e307e473fa2a55d4a05da802ee2feb65c85c63b9019c83747b23"

  bottle do
    revision 1
    sha256 "cb45299c0a279d0cf67a3f0de1875b78f6944cf899ae9844ba6cfc8f39689599" => :el_capitan
    sha1 "29eeb5e7ddc45ea4c3a5a3f47304082a44046413" => :yosemite
    sha1 "f1c1939e7ea13ba07997f563c8d275195dae9679" => :mavericks
    sha1 "ac76937c8a7dded8bb89f1ece1ea9ede2f8e41a4" => :mountain_lion
  end

  depends_on "open-sp"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
