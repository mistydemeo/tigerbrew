class Libdvdcss < Formula
  desc "Access DVDs as block devices without the decryption"
  homepage "https://www.videolan.org/developers/libdvdcss.html"
  url "https://download.videolan.org/pub/videolan/libdvdcss/1.3.99/libdvdcss-1.3.99.tar.bz2"
  sha256 "08b0fab9171b338cbbe07b3a4ea227d991d5f1665717780df5030abbbd9b5c5d"

  head do
    url "git://git.videolan.org/libdvdcss"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end


  def install
    system "autoreconf", "-if" if build.head?
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make", "install"
  end
end
