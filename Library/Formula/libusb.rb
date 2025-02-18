class Libusb < Formula
  desc "Library for USB device access"
  homepage "https://libusb.info/"
  url "https://github.com/libusb/libusb/releases/download/v1.0.23/libusb-1.0.23.tar.bz2"
  sha256 "db11c06e958a82dac52cf3c65cb4dd2c3f339c8a988665110e0d24d19312ad8d"
  license "LGPL-2.1-or-later"

  bottle do
    sha256 "73b540f092915bee23b2afd8735ccc94b3fa150efbcdd7921f7ef3d4da9984e1" => :tiger_altivec
  end

  # USB 3.0 support showed up in 10.8's IOKit
  patch :p0, :DATA

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
__END__
--- libusb/os/darwin_usb.c.orig	2025-02-18 13:42:51.000000000 +0000
+++ libusb/os/darwin_usb.c	2025-02-18 13:43:02.000000000 +0000
@@ -1099,7 +1099,7 @@
     case kUSBDeviceSpeedLow: dev->speed = LIBUSB_SPEED_LOW; break;
     case kUSBDeviceSpeedFull: dev->speed = LIBUSB_SPEED_FULL; break;
     case kUSBDeviceSpeedHigh: dev->speed = LIBUSB_SPEED_HIGH; break;
-#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
+#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1080
     case kUSBDeviceSpeedSuper: dev->speed = LIBUSB_SPEED_SUPER; break;
 #endif
 #if MAC_OS_X_VERSION_MAX_ALLOWED >= 101200
