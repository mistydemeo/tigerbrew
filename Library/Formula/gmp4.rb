class Gmp4 < Formula
  desc "GNU multiple precision arithmetic library"
  homepage "https://gmplib.org/"
  # Track gcc infrastructure releases.
  url "https://ftpmirror.gnu.org/gmp/gmp-4.3.2.tar.bz2"
  mirror "https://ftp.gnu.org/gnu/gmp/gmp-4.3.2.tar.bz2"
  mirror "ftp://ftp.gmplib.org/pub/gmp-4.3.2/gmp-4.3.2.tar.bz2"
  mirror "ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-4.3.2.tar.bz2"
  sha256 "936162c0312886c21581002b79932829aa048cfaf9937c6265aeaa14f1cd1775"

  bottle do
    cellar :any
    sha256 "80fab08e90d3e536b21d0826580d9f78f0e8542f7f08d5cde866307fcf187db1" => :tiger_altivec
  end

  keg_only "Conflicts with gmp in main repository."

  option "with-32-bit"

  deprecated_option "32-bit" => "with-32-bit"

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
    system "make", "check"
    ENV.deparallelize # Doesn't install in parallel on 8-core Mac Pro
    system "make", "install"
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
