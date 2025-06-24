class Ffts < Formula
  desc "C library that computes the discrete Fourier transform"
  homepage "http://anthonix.com/ffts/"
  head "https://github.com/anthonix/ffts.git"
  url "http://anthonix.com/ffts/releases/ffts-0.7.tar.gz"
  sha256 "6362e498e5aa241661cfe9060153076b78e300a5d3c365997ba6ac2f637df3ff"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-sse",
                          "--enable-single"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <ffts/ffts.h>
      #define align(x) __attribute__((aligned(x)))
      int main(void) {
          const size_t    n         = 8;
          float align(32) input[n]  = {0.0, };
          float align(32) output[n];
          ffts_plan_t*    plan      = ffts_init_1d(n, 1);
          ffts_execute(plan, input, output);
          ffts_free(plan);
      }
    EOS
    system ENV.cc, "test.c", "-lffts", "-o", "test"
    system "./test"
  end
end
