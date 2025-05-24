class Libidn < Formula
  desc "International domain name library"
  homepage "https://www.gnu.org/software/libidn/"
  url "http://ftpmirror.gnu.org/libidn/libidn-1.32.tar.gz"
  mirror "https://ftp.gnu.org/gnu/libidn/libidn-1.32.tar.gz"
  sha256 "ba5d5afee2beff703a34ee094668da5c6ea5afa38784cebba8924105e185c4f5"


  option :universal

  depends_on "pkg-config" => :build

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-csharp",
                          "--with-lispdir=#{share}/emacs/site-lisp/#{name}"
    system "make", "install"
  end

  test do
    ENV["CHARSET"] = "UTF-8"
    system "#{bin}/idn", "räksmörgås.se", "blåbærgrød.no"
  end
end
