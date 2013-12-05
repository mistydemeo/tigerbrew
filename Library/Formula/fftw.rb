require 'formula'

class Fftw < Formula
  homepage 'http://www.fftw.org'
  url 'http://www.fftw.org/fftw-3.3.3.tar.gz'
  sha1 '11487180928d05746d431ebe7a176b52fe205cf9'

  option "with-fortran", "Enable Fortran bindings"

  depends_on :fortran => :optional

  def install
    args = ["--enable-shared",
            "--disable-debug",
            "--prefix=#{prefix}",
            "--enable-threads",
            "--disable-dependency-tracking"]
    simd_args = ["--enable-sse2"]
    simd_args << "--enable-avx" if ENV.compiler == :clang and Hardware::CPU.avx? and !build.bottle?

    args << "--disable-fortran" unless build.with? "fortran"

    # Decide which SIMD options we need
    simd_single = []
    simd_double = []

    if Hardware.cpu_type == :intel
      simd_single << "--enable-sse"
      simd_double << "--enable-sse2"
    elsif Hardware::CPU.type == :ppc && Hardware::CPU.family != :g3
      simd_single << "--enable-altivec" # altivec seems to only work with single precision
    end

    # single precision
    # enable-sse only works with single
    # similarly altivec only works with single precision
    system "./configure", "--enable-single",
                          simd_single,
                          *args
    system "make install"

    # clean up so we can compile the double precision variant
    system "make clean"

    # double precision
    # enable-sse2 only works with double precision (default)
    system "./configure", simd_double, *args
    system "make install"

    # clean up so we can compile the long-double precision variant
    system "make clean"

    # long-double precision
    # no SIMD optimization available
    system "./configure", "--enable-long-double", *args
    system "make install"
  end

  test do
    # Adapted from the sample usage provided in the documentation:
    # http://www.fftw.org/fftw3_doc/Complex-One_002dDimensional-DFTs.html
    (testpath/'fftw.c').write <<-TEST_SCRIPT.undent
      #include <fftw3.h>

      int main(int argc, char* *argv)
      {
          fftw_complex *in, *out;
          fftw_plan p;
          long N = 1;
          in = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * N);
          out = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * N);
          p = fftw_plan_dft_1d(N, in, out, FFTW_FORWARD, FFTW_ESTIMATE);
          fftw_execute(p); /* repeat as needed */
          fftw_destroy_plan(p);
          fftw_free(in); fftw_free(out);
          return 0;
      }
    TEST_SCRIPT

    system ENV.cc, '-o', 'fftw', 'fftw.c', '-lfftw3', *ENV.cflags.split
    system './fftw'
  end
end
