class Norm < Formula
  desc "NACK-Oriented Reliable Multicast"
  homepage "https://www.nrl.navy.mil/itd/ncs/products/norm"
  url "https://downloads.pf.itd.nrl.navy.mil/norm/archive/src-norm-1.5r6.tgz"
  mirror "https://web.archive.org/web/20161223160402/https://downloads.pf.itd.nrl.navy.mil/norm/archive/src-norm-1.5r6.tgz"
  version "1.5r6"
  sha256 "20ea2e8dd5d5e1ff1ff91dc7dab6db53a77d7b7183d8cf2425c215fd294f22a7"


  def install
    system "./waf", "configure", "--prefix=#{prefix}"
    system "./waf", "install"
    include.install "include/normApi.h"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <assert.h>
      #include <normApi.h>

      int main()
      {
        NormInstanceHandle i;
        i = NormCreateInstance(false);
        assert(i != NORM_INSTANCE_INVALID);
        NormDestroyInstance(i);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lnorm", "-o", "test"
    system "./test"
  end
end
