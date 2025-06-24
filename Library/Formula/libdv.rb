class Libdv < Formula
  desc "Codec for DV video encoding format"
  homepage "http://libdv.sourceforge.net"
  url "https://downloads.sourceforge.net/libdv/libdv-1.0.0.tar.gz"
  sha256 "a305734033a9c25541a59e8dd1c254409953269ea7c710c39e540bd8853389ba"


  depends_on "popt"

  def install
    # This fixes an undefined symbol error on compile.
    # See the port file for libdv. http://libdv.darwinports.com/
    # This flag is the preferred method over what macports uses.
    # See the apple docs: http://cl.ly/2HeF bottom of the "Finding Imported Symbols" section
    ENV.append "LDFLAGS", "-undefined dynamic_lookup"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-gtktest",
                          "--disable-gtk",
                          "--disable-asm",
                          "--disable-sdltest"
    system "make", "install"
  end
end
