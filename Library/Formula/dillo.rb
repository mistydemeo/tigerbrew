class Dillo < Formula
  desc "Dillo is a fast and small graphical web browser"
  homepage "https://dillo-browser.github.io"
  url "https://github.com/dillo-browser/dillo/releases/download/v3.1.0/dillo-3.1.0.tar.bz2"
  version "3.1.0"
  sha256 "f56766956d90dac0ccca31755917cba8a4014bcf43b3e36c7d86efe1d20f9d92"

  bottle do
    sha256 "175c4bb73ec0bc8c588f11752e4ec674a77947cd28fec00e4da1038261e35c72" => :tiger_altivec
  end

  depends_on "make" => :build
  depends_on "fltk"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "openssl3"
  depends_on "wget" => :run
  depends_on "zlib"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-ca-certs-file=#{etc}/openssl@3/cert.pem"
    system "gmake", "install"
  end
end
