class Ola < Formula
  desc "Open Lighting Architecture for lighting control information"
  homepage "https://www.openlighting.org/ola/"
  url "https://github.com/OpenLightingProject/ola/releases/download/0.9.7/ola-0.9.7.tar.gz"
  sha256 "ce0edd8eac644fc753f2289c1998e5a4829d74246acecd06f73619a5a09206e1"


  head do
    url "https://github.com/OpenLightingProject/ola.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option :universal

  depends_on "pkg-config" => :build
  depends_on "cppunit"
  depends_on "protobuf-c"
  depends_on "libmicrohttpd"
  depends_on "libusb"
  depends_on "liblo"
  depends_on "ossp-uuid"
  depends_on :python => :optional
  depends_on "doxygen" => :optional

  def install
    ENV.universal_binary if build.universal?

    args = %W[
      --disable-fatal-warnings
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
    ]

    args << "--enable-python-libs" if build.with? "python"
    args << "--enable-doxygen-man" if build.with? "doxygen"

    system "autoreconf", "-i" if build.head?
    system "./configure", *args
    system "make", "install"
  end

  test do
    system bin/"ola_plugin_info"
  end
end
