class Libspiro < Formula
  desc "Library to simplify the drawing of curves"
  homepage "https://github.com/fontforge/libspiro"
  url "https://downloads.sourceforge.net/project/libspiro/libspiro/20071029/libspiro_src-20071029.tar.bz2"
  sha256 "1efeb1527bd48f8787281e8be1d0e8ff2e584d4c1994a0bc2f6859be2ffad4cf"


  head do
    url "https://github.com/fontforge/libspiro.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  def install
    if build.head?
      system "autoreconf", "-i"
      system "automake"
    end

    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end
end
