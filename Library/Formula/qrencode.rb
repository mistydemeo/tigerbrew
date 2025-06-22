class Qrencode < Formula
  desc "QR Code generation"
  homepage "https://fukuchi.org/en/works/qrencode/index.html"
  url "https://fukuchi.org/works/qrencode/qrencode-3.4.4.tar.gz"
  sha256 "e794e26a96019013c0e3665cb06b18992668f352c5553d0a553f5d144f7f2a72"

  bottle do
    cellar :any
    sha256 "199fe87d536ffab8075f49d0fc95ddb1a3c45db8cdc26cfc6c2aa3a4b1379c0a" => :el_capitan
    sha1 "2a79a4f7f5dce4490e31cab8277f3a492e77aa4a" => :yosemite
    sha1 "26e2a0641f7556fe3e7d44da7b05644c25b1ae04" => :mavericks
    sha1 "f0797c8fd3b500f79300868248c07d3144712a96" => :mountain_lion
  end

  head do
    url "https://github.com/fukuchi/libqrencode.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "libpng"

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/qrencode", "123456789", "-o", "test.png"
  end
end
