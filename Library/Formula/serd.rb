class Serd < Formula
  desc "C library for RDF syntax"
  homepage "http://drobilla.net/software/serd/"
  url "http://download.drobilla.net/serd-0.20.0.tar.bz2"
  sha256 "64515f4f5eb27ba2ba151027a72a77672f6ee8a2a3b58991ad5c045135feabbf"


  depends_on "pkg-config" => :build

  def install
    system "./waf", "configure", "--prefix=#{prefix}"
    system "./waf"
    system "./waf", "install"
  end
end
