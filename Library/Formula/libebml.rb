class Libebml < Formula
  desc "Sort of a sbinary version of XML"
  homepage "http://www.matroska.org/"
  url "http://dl.matroska.org/downloads/libebml/libebml-1.3.1.tar.bz2"
  mirror "https://www.bunkus.org/videotools/mkvtoolnix/sources/libebml-1.3.1.tar.bz2"
  sha256 "195894b31aaca55657c9bc157d744f23b0c25597606b97cfa5a9039c4b684295"

  head do
    url "https://github.com/Matroska-Org/libebml.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end


  option :cxx11

  def install
    ENV.cxx11 if build.cxx11?
    system "autoreconf", "-fi" if build.head?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
