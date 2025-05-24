class Rarian < Formula
  desc "Documentation metadata library"
  homepage "http://rarian.freedesktop.org/"
  url "http://rarian.freedesktop.org/Releases/rarian-0.8.1.tar.bz2"
  sha256 "aafe886d46e467eb3414e91fa9e42955bd4b618c3e19c42c773026b205a84577"


  conflicts_with "scrollkeeper",
    :because => "rarian and scrollkeeper install the same binaries."

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
