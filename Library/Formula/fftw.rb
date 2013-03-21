require 'formula'

class Fftw < Formula
  homepage 'http://www.fftw.org'
  url 'http://www.fftw.org/fftw-3.3.3.tar.gz'
  sha1 '11487180928d05746d431ebe7a176b52fe205cf9'

  option "with-fortran", "Enable Fortran bindings"

  def install
    args = ["--enable-shared",
            "--disable-debug",
            "--prefix=#{prefix}",
            "--enable-threads",
            "--disable-dependency-tracking"]

    if build.include? "with-fortran"
      ENV.fortran
    else
      args << "--disable-fortran" unless which 'gfortran'
    end

    # Decide which SIMD options we need
    simd_single = []
    simd_double = []

    if Hardware.cpu_type == :intel
      simd_single << "--enable-sse"
      simd_double << "--enable-sse2"
    elsif Hardware.ppc_family != :g3
      simd_single << "--enable-altivec" # altivec seems to only work with
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
end
