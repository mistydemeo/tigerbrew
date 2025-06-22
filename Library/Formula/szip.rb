class Szip < Formula
  desc "Implementation of extended-Rice lossless compression algorithm"
  homepage "https://docs.hdfgroup.org/archive/support/doc_resource/SZIP/index.html"
  url "http://www.hdfgroup.org/ftp/lib-external/szip/2.1/src/szip-2.1.tar.gz"
  sha256 "a816d95d5662e8279625abdbea7d0e62157d7d1f028020b1075500bf483ed5ef"

  bottle do
    cellar :any
    sha256 "2c86ae818283805e5c34285be965d396e3d11ff9ebb144baf78696f69dc10beb" => :el_capitan
    sha1 "75413c328dc915c2bc638d308fd15a1e93fddd18" => :yosemite
    sha1 "71a91cec13090ab85a0b1c7339df98610561562d" => :mavericks
    sha1 "37a8018d670680d3002fd68aec8fae0992635911" => :mountain_lion
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <assert.h>
      #include <stdlib.h>
      #include <stdio.h>
      #include "szlib.h"

      int main()
      {
        sz_stream c_stream;
        c_stream.bits_per_pixel = 8;
        c_stream.pixels_per_block = 8;
        c_stream.pixels_per_scanline = 16;
        assert(SZ_CompressInit(&c_stream) == SZ_OK);
        assert(SZ_CompressEnd(&c_stream) == SZ_OK);
        return 0;
      }
    EOS
    system ENV.cc, "-lsz", "test.c", "-o", "test"
    system "./test"
  end
end
