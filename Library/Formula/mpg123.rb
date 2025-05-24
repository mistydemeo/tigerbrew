class Mpg123 < Formula
  desc "MP3 player for Linux and UNIX"
  homepage "http://www.mpg123.de/"
  url "http://www.mpg123.de/download/mpg123-1.22.4.tar.bz2"
  mirror "http://mpg123.orgis.org/download/mpg123-1.22.4.tar.bz2"
  sha256 "5069e02e50138600f10cc5f7674e44e9bf6f1930af81d0e1d2f869b3c0ee40d2"


  def install
    args = ["--disable-debug", "--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--with-default-audio=coreaudio",
            "--with-module-suffix=.so"]

    if Hardware::CPU.type == :intel
      if MacOS.prefer_64_bit?
        args << "--with-cpu=x86-64"
      else
        args << "--with-cpu=sse_alone"
      end
    elsif Hardware::CPU.type == :ppc
      args << "--with-cpu=altivec" if Hardware::CPU.altivec?
    end

    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{bin}/mpg123", test_fixtures("test.mp3")
  end
end
