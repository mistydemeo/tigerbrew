class Fftw < Formula
  desc "C routines to compute the Discrete Fourier Transform"
  homepage "http://www.fftw.org"
  url "http://www.fftw.org/fftw-3.3.4.tar.gz"
  sha256 "8f0cde90929bc05587c3368d2f15cd0530a60b8a9912a8e2979a72dbe5af0982"
  revision 1

  bottle do
    cellar :any
    sha256 "36a37f90f5c820881349771ace8a8c6074afc9e92e8b28d54ec11b64212842ae" => :tiger_altivec
    sha256 "b0674fe02a9eb76161b67d17e14fd03ea8c826874b3172a7033fb0f55d3f9ab7" => :leopard_g3
    sha256 "1440b812fd8d0c65a10be62ad4dd3885c6feab1679d677377ff483a4e1342ee0" => :leopard_altivec
  end

  option "with-fortran", "Enable Fortran bindings"
  option :universal
  option "with-mpi", "Enable MPI parallel transforms"
  option "with-openmp", "Enable OpenMP parallel transforms"

  depends_on :fortran => :optional
  depends_on :mpi => [:cc, :optional]
  needs :openmp if build.with? "openmp"

  def install
    args = ["--enable-shared",
            "--disable-debug",
            "--prefix=#{prefix}",
            "--enable-threads",
            "--disable-dependency-tracking"]
    simd_args = ["--enable-sse2"]
    simd_args << "--enable-avx" if ENV.compiler == :clang && Hardware::CPU.avx? && !build.bottle?

    args << "--disable-fortran" if build.without? "fortran"
    args << "--enable-mpi" if build.with? "mpi"
    args << "--enable-openmp" if build.with? "openmp"

    # Decide which SIMD options we need
    simd_single = []
    simd_double = []

    if Hardware.cpu_type == :intel
      # enable-sse2 and enable-avx works for both single and double precision
      simd_single = ["--enable-sse2"]
      simd_single << "--enable-avx" if ENV.compiler == :clang && Hardware::CPU.avx? && !build.bottle?
      simd_double = simd_single
    elsif Hardware::CPU.altivec? && !(build.bottle? && ARGV.bottle_arch == :g3)
      simd_single << "--enable-altivec" # altivec seems to only work with single precision
    end

    ENV.universal_binary if build.universal?

    # single precision
    # enable-sse only works with single
    # similarly altivec only works with single precision
    system "./configure", "--enable-single",
                          *(simd_single + args)
    system "make", "install"

    # clean up so we can compile the double precision variant
    system "make", "clean"

    # double precision
    # enable-sse2 only works with double precision (default)
    system "./configure", *(simd_double + args)
    system "make", "install"

    # clean up so we can compile the long-double precision variant
    system "make", "clean"

    # long-double precision
    # no SIMD optimization available
    system "./configure", "--enable-long-double", *args
    system "make", "install"
  end

  test do
    # Adapted from the sample usage provided in the documentation:
    # http://www.fftw.org/fftw3_doc/Complex-One_002dDimensional-DFTs.html
    (testpath/"fftw.c").write <<-TEST_SCRIPT.undent
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

    system ENV.cc, "-o", "fftw", "fftw.c", "-lfftw3", *ENV.cflags.to_s.split
    system "./fftw"
  end
end
