class Gphoto2 < Formula
  desc "Command-line interface to libgphoto2"
  homepage "http://gphoto.org/"
  url "http://downloads.sourceforge.net/project/gphoto/gphoto/2.5.1/gphoto2-2.5.1.tar.bz2"
  sha1 "c363adfb5d0f21c03bc5dc27daf19e9e409832ec"
  revision 2

  depends_on "pkg-config" => :build
  depends_on "jpeg"
  depends_on "libgphoto2"
  depends_on "popt"
  depends_on "readline"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
