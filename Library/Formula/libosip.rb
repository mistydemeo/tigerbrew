class Libosip < Formula
  desc "Implementation of the eXosip2 stack"
  homepage "https://www.gnu.org/software/osip/"
  url "http://ftpmirror.gnu.org/osip/libosip2-4.1.0.tar.gz"
  mirror "https://ftp.gnu.org/gnu/osip/libosip2-4.1.0.tar.gz"
  sha256 "996aa0363316a871915b6f12562af53853a9962bb93f6abe1ae69f8de7008504"


  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
