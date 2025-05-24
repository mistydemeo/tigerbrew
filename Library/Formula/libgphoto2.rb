class Libgphoto2 < Formula
  desc "Gphoto2 digital camera library"
  homepage "http://www.gphoto.org/proj/libgphoto2/"
  # Sourceforge URL is still down
  url "https://fossies.org/linux/privat/libgphoto2-2.5.8.tar.bz2"
  sha256 "031a262e342fae43f724afe66787947ce1fb483277dfe5a8cf1fbe92c58e27b6"


  option :universal

  depends_on "pkg-config" => :build
  depends_on "libtool" => :run
  depends_on "libusb-compat"
  depends_on "gd"
  depends_on "libexif" => :optional

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
