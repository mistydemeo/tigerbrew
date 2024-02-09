class Libusb < Formula
  desc "Library for USB device access"
  homepage "https://libusb.info/"
  url "https://github.com/libusb/libusb/releases/download/v1.0.23/libusb-1.0.23.tar.bz2"
  # sha256 "12ce7a61fc9854d1d2a1ffe095f7b5fac19ddba095c259e6067a46500381b5a5"
  sha256 "db11c06e958a82dac52cf3c65cb4dd2c3f339c8a988665110e0d24d19312ad8d"
  license "LGPL-2.1-or-later"

  bottle do
  end

  head do
    url "https://github.com/libusb/libusb.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def install
    args = %W[--disable-dependency-tracking --prefix=#{prefix}]

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make", "install"
    (pkgshare/"examples").install Dir["examples/*"] - Dir["examples/Makefile*"]
  end

  test do
    cp_r (pkgshare/"examples"), testpath
    cd "examples" do
      system ENV.cc, "listdevs.c", "-L#{lib}", "-I#{include}/libusb-1.0",
             "-lusb-1.0", "-o", "test"
      system "./test"
    end
  end
end
