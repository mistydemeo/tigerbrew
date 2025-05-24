class Snap7 < Formula
  desc "Ethernet communication suite that works natively with Siemens S7 PLCs"
  homepage "http://snap7.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/snap7/1.4.0/snap7-full-1.4.0.tar.gz"
  sha256 "5d2a4948a65e0ad2a52b1a7981f3c3209be0ef821f3d00756ee0584cf4b762bb"


  def install
    lib.mkpath
    system "make", "-C", "build/osx",
                   "-f", "#{MacOS.preferred_arch}_osx.mk",
                   "install", "LibInstall=#{lib}"
    include.install "release/Wrappers/c-cpp/snap7.h"
  end

  test do
    system "python", "-c", "import ctypes.util,sys;ctypes.util.find_library('snap7') or sys.exit(1)"
  end
end
