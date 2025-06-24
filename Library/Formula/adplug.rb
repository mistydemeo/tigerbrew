class Adplug < Formula
  desc "Free, hardware independent AdLib sound player library"
  homepage "http://adplug.sf.net"
  url "https://downloads.sourceforge.net/project/adplug/AdPlug%20core%20library/2.2.1/adplug-2.2.1.tar.bz2"
  sha256 "f95a015268a0dfe9ff5782f3ea7b2a69e09b8d36ccd19ebf4d979d767b6e53ef"


  depends_on "pkg-config" => :build
  depends_on "libbinio"

  resource "ksms" do
    url "http://advsys.net/ken/ksmsongs.zip"
    sha256 "2af9bfc390f545bc7f51b834e46eb0b989833b11058e812200d485a5591c5877"
  end

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    resource("ksms").stage do
      mkdir "#{testpath}/.adplug"
      system "#{bin}/adplugdb", "-v", "add", "JAZZSONG.KSM"
    end
  end
end
