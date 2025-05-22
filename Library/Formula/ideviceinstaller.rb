class Ideviceinstaller < Formula
  desc "Cross-platform library and tools for communicating with iOS devices"
  homepage "http://www.libimobiledevice.org/"
  url "http://www.libimobiledevice.org/downloads/ideviceinstaller-1.1.0.tar.bz2"
  sha256 "0821b8d3ca6153d9bf82ceba2706f7bd0e3f07b90a138d79c2448e42362e2f53"
  revision 1


  head do
    url "http://git.sukimashita.com/ideviceinstaller.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "libimobiledevice"
  depends_on "libzip"

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/ideviceinstaller --help |grep -q ^Usage"
  end
end
