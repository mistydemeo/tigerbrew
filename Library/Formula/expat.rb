require 'formula'

class Expat < Formula
  homepage 'http://expat.sourceforge.net/'
  url 'https://downloads.sourceforge.net/project/expat/expat/2.1.0/expat-2.1.0.tar.gz'
  sha1 'b08197d146930a5543a7b99e871cba3da614f6f0'

  bottle do
    cellar :any
    sha1 "4e8738f61c4cdb18b9278c3fc9c9e9a5e56371ab" => :tiger_altivec
    sha1 "a196b61b812943c1687a88b593a35c650c8bdec3" => :leopard_g3
    sha1 "b9de95ab617c38d84197294dc018c1056fd82f4b" => :leopard_altivec
  end

  keg_only :provided_by_osx, "OS X includes Expat 1.5." if MacOS.version > :tiger

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make install"
  end
end
