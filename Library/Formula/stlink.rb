class Stlink < Formula
  desc "stm32 discovery line Linux programmer"
  homepage "https://github.com/stlink-org/stlink"
  url "https://github.com/stlink-org/stlink/archive/refs/tags/v1.7.0.zip"
  sha256 "dd2fde56c701b9084f6c60c5d2549673150b596f06cffe1334f498013a97f0e1"

  bottle do
    cellar :any
    sha256 "3e7284432576b03b20adb80e29c334a1f205e66b24b01ab6a82b6bc2907bc42b" => :tiger_g3
  end

  # Don't assume the compiler will default to C99
  # Need to enable warnings otherwise libtool trips up, skip treating warnings as errors.
  patch :p0, :DATA

  depends_on "pkg-config" => :build
  depends_on "cmake" => :build
  depends_on "libusb"

  def install
    # libtool: unknown option character `w' in: -w
    ENV.enable_warnings if ENV.compiler == :gcc_4_0

    system "cmake", ".", *std_cmake_args
    system "make"
    system "make", "install"
  end

  test do
    system "st-util", "-h"
  end
end
__END__
--- cmake/modules/c_flags.cmake.orig	2025-11-11 20:19:40.000000000 +0000
+++ cmake/modules/c_flags.cmake	2025-11-11 20:19:53.000000000 +0000
@@ -17,6 +17,7 @@
     endif ()
 endfunction()
 
+add_cflag_if_supported("-std=gnu99")
 add_cflag_if_supported("-std=gnu11")
 add_cflag_if_supported("-std=gnu18")
 add_cflag_if_supported("-Wall")
@@ -50,5 +51,4 @@
     add_cflag_if_supported("-O0")
 else ()
     add_cflag_if_supported("-O2")
-    add_cflag_if_supported("-Werror")
 endif ()
