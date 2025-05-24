class Libdvdnav < Formula
  desc "DVD navigation library"
  homepage "https://dvdnav.mplayerhq.hu/"
  url "https://download.videolan.org/pub/videolan/libdvdnav/5.0.3/libdvdnav-5.0.3.tar.bz2"
  sha256 "5097023e3d2b36944c763f1df707ee06b19dc639b2b68fb30113a5f2cbf60b6d"

  head do
    url "git://git.videolan.org/libdvdnav.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end


  depends_on "pkg-config" => :build
  depends_on "libdvdread"

  def install
    system "autoreconf", "-if" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
