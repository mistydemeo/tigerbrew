class Portaudio < Formula
  desc "Cross-platform library for audio I/O"
  homepage "http://www.portaudio.com"
  url "http://www.portaudio.com/archives/pa_stable_v19_20140130.tgz"
  sha256 "8fe024a5f0681e112c6979808f684c3516061cc51d3acc0b726af98fc96c8d57"
  head "https://subversion.assembla.com/svn/portaudio/portaudio/trunk/", :using => :svn


  depends_on "pkg-config" => :build

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--enable-mac-universal=#{build.universal? ? "yes" : "no"}",
                          "--enable-cxx"
    system "make", "install"

    # Need 'pa_mac_core.h' to compile PyAudio
    include.install "include/pa_mac_core.h"
  end
end
