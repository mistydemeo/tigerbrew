class Libmpdclient < Formula
  desc "Library for MPD in the C, C++, and Objective-C languages"
  homepage "http://www.musicpd.org/libs/libmpdclient/"
  url "http://www.musicpd.org/download/libmpdclient/2/libmpdclient-2.10.tar.gz"
  sha256 "bf88ddd9beceadef11144811adaabe45008005af02373595daa03446e6b1bf3d"


  head do
    url "git://git.musicpd.org/master/libmpdclient.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "doxygen" => :build

  option :universal

  def install
    inreplace "autogen.sh", "libtoolize", "glibtoolize"
    system "./autogen.sh" if build.head?

    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
