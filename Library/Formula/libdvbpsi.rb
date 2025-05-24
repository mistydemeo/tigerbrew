class Libdvbpsi < Formula
  desc "Library to decode/generate MPEG TS and DVB PSI tables"
  homepage "https://www.videolan.org/developers/libdvbpsi.html"
  url "https://download.videolan.org/pub/libdvbpsi/0.2.2/libdvbpsi-0.2.2.tar.bz2"
  sha256 "9aa62345c8fed04a4f59524967fb154e3f9b02625666a200861555dcb9163ed3"


  def install
    # Clang doesn't recognize O6.  Just remove it.  Fixes a build error.
    inreplace "configure", "CFLAGS=\"${CFLAGS} -O6\"", "CFLAGS=\"${CFLAGS}\""
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking", "--enable-release"
    system "make", "install"
  end
end
