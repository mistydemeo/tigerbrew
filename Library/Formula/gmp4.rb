class Gmp4 < Formula
  desc "GNU multiple precision arithmetic library"
  homepage "http://gmplib.org/"
  # Track gcc infrastructure releases.
  url "https://ftpmirror.gnu.org/gmp/gmp-4.3.2.tar.bz2"
  mirror "https://ftp.gnu.org/gnu/gmp/gmp-4.3.2.tar.bz2"
  mirror "ftp://ftp.gmplib.org/pub/gmp-4.3.2/gmp-4.3.2.tar.bz2"
  mirror "ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-4.3.2.tar.bz2"
  sha256 "936162c0312886c21581002b79932829aa048cfaf9937c6265aeaa14f1cd1775"

  bottle do
    cellar :any
    revision 1
    sha256 "5c5d632ea58479fba37a0844d0b9a4fd1e865e809286ada95d5484d72ab50a78" => :el_capitan
    sha256 "932a2d0987dd26bbc3cb54b7d38d4cf6b0e5a4bd46fef8442b79b75f067abf6e" => :yosemite
    sha256 "b7012c46ac9e5b5aa1004184e85a2e99fc047d9f92f1e8b82699ba1f1ea1f7bf" => :mavericks
  end

  keg_only "Conflicts with gmp in main repository."

  option "with-32-bit"
  option "without-check", "Do not run `make check` to verify libraries"

  deprecated_option "32-bit" => "with-32-bit"
  deprecated_option "skip-check" => "without-check"

  fails_with :gcc_4_0 do
    cause "Reports of problems using gcc 4.0 on Leopard: https://github.com/mxcl/homebrew/issues/issue/2302"
  end

  # Patches gmp.h to remove the __need_size_t define, which
  # was preventing libc++ builds from getting the ptrdiff_t type
  # Applied upstream in http://gmplib.org:8000/gmp/raw-rev/6cd3658f5621
  patch :DATA

  def install
    args = ["--prefix=#{prefix}", "--enable-cxx"]

    # Build 32-bit where appropriate, and help configure find 64-bit CPUs
    if MacOS.prefer_64_bit? && !build.build_32_bit?
      ENV.m64
      args << "--build=x86_64-apple-darwin"
    else
      ENV.m32
      args << "--host=none-apple-darwin"
    end

    system "./configure", *args
    system "make"
    ENV.deparallelize # Doesn't install in parallel on 8-core Mac Pro
    system "make", "install"

    # Different compilers and options can cause tests to fail even
    # if everything compiles, so yes, we want to do this step.
    system "make", "check" if build.with? "check"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <gmp.h>

      int main()
      {
        mpz_t integ;
        mpz_init (integ);
        mpz_clear (integ);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lgmp", "-I#{include}", "-o", "test"
    system "./test"
  end
end

__END__
diff --git a/gmp-h.in b/gmp-h.in
index d7fbc34..3c57c48 100644
--- a/gmp-h.in
+++ b/gmp-h.in
@@ -46,13 +46,11 @@ along with the GNU MP Library.  If not, see http://www.gnu.org/licenses/.  */
 #ifndef __GNU_MP__
 #define __GNU_MP__ 4
 
-#define __need_size_t  /* tell gcc stddef.h we only want size_t */
 #if defined (__cplusplus)
 #include <cstddef>     /* for size_t */
 #else
 #include <stddef.h>    /* for size_t */
 #endif
-#undef __need_size_t
 
 /* Instantiated by configure. */
 #if ! defined (__GMP_WITHIN_CONFIGURE)
