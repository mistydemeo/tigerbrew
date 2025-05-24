class Kytea < Formula
  desc "Toolkit for analyzing text, especially Japanese and Chinese"
  homepage "http://www.phontron.com/kytea/"
  url "http://www.phontron.com/kytea/download/kytea-0.4.7.tar.gz"
  sha256 "534a33d40c4dc5421f053c71a75695c377df737169f965573175df5d2cff9f46"


  head do
    url "https://github.com/neubig/kytea.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def install
    system "autoreconf", "-i" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
