class Gpsbabel < Formula
  desc "GPSBabel converts/uploads GPS waypoints, tracks, and routes"
  homepage "https://www.gpsbabel.org/"
  url "http://gpsbabel.googlecode.com/svn/trunk/gpsbabel", :revision => "4962"
  version "1.5.2"

  head "http://gpsbabel.googlecode.com/svn/trunk/gpsbabel"


  depends_on "libusb" => :optional
  depends_on "qt"

  def install
    args = ["--disable-debug", "--disable-dependency-tracking",
            "--prefix=#{prefix}", "--with-zlib=system"]
    args << "--without-libusb" if build.without? "libusb"
    system "./configure", *args
    system "make", "install"
  end
end
