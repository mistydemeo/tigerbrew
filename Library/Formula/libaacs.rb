class Libaacs < Formula
  desc "Implements the Advanced Access Content System specification"
  homepage "https://www.videolan.org/developers/libaacs.html"
  url "https://download.videolan.org/pub/videolan/libaacs/0.8.1/libaacs-0.8.1.tar.bz2"
  mirror "http://videolan-nyc.defaultroute.com/libaacs/0.8.1/libaacs-0.8.1.tar.bz2"
  sha256 "95c344a02c47c9753c50a5386fdfb8313f9e4e95949a5c523a452f0bcb01bbe8"


  head do
    url "git://git.videolan.org/libaacs.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "bison" => :build
  depends_on "libgcrypt"

  def install
    system "./bootstrap" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
