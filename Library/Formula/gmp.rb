class Gmp < Formula
  desc "GNU multiple precision arithmetic library"
  homepage "https://gmplib.org/"
  url "https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gmp/gmp-6.2.1.tar.xz"
  sha256 "fd4829912cddd12f84181c3451cc752be224643e87fac497b69edddadc49b4f2"

  bottle do
    sha256 "8959b62e4b35331839445da5d5047bde738d7a53ab0abfe08f24249f135c3312" => :tiger_altivec
  end

  # "suffix or operands invalid for movq"
  # https://www.mail-archive.com/gmp-bugs@gmplib.org/msg01321.html
  # https://gmplib.org/repo/gmp/rev/3ac5afa36be5
  patch :DATA

  option "32-bit"
  option :cxx11

  def arch_to_string_map
    @arch_map ||= {
      :g3  => "powerpc750",
      :g4  => "powerpc7400",
      :g4e => "powerpc7450",
      :g5  => "powerpc970"
    }
  end

  # https://github.com/mistydemeo/tigerbrew/issues/212
  env :std

  def install
    ENV.cxx11 if build.cxx11?
    args = ["--prefix=#{prefix}", "--enable-cxx"]
    if build.bottle?
      bottle_sym = ARGV.bottle_arch || Hardware.oldest_cpu
      arch = arch_to_string_map.fetch(bottle_sym, "core2")
      args << "--build=#{arch}-apple-darwin#{`uname -r`.to_i}"
    end

    if build.build_32_bit? || !MacOS.prefer_64_bit?
      ENV.m32
      args << "ABI=32"
    end

    ENV.append_to_cflags "-force_cpusubtype_ALL" if Hardware.cpu_type == :ppc
    # https://github.com/Homebrew/homebrew/issues/20693
    args << "--disable-assembly" if build.build_32_bit? || build.bottle?

    system "./configure", "--disable-static", *args
    system "make"
    system "make", "check"
    system "make", "install"
    system "make", "clean"
    system "./configure", "--disable-shared", "--disable-assembly", *args
    system "make"
    lib.install Dir[".libs/*.a"]
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <gmp.h>
      #include <stdlib.h>

      int main() {
        mpz_t i, j, k;
        mpz_init_set_str (i, "1a", 16);
        mpz_init (j);
        mpz_init (k);
        mpz_sqrtrem (j, k, i);
        if (mpz_get_si (j) != 5 || mpz_get_si (k) != 1) abort();
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lgmp", "-o", "test"
    system "./test"
  end
end
__END__
--- a/mpn/x86_64/bd1/hamdist.asm	Fri Oct 28 16:31:44 2022 +0200
+++ b/mpn/x86_64/bd1/hamdist.asm	Wed Nov 02 13:48:37 2022 +0100
@@ -170,7 +170,7 @@
 	paddq	%xmm0, %xmm8
 	pshufd	$14, %xmm8, %xmm0
 	paddq	%xmm8, %xmm0
-	movq	%xmm0, %rax
+	movd	%xmm0, %rax
 	add	%r10, %rax
 	FUNC_EXIT()
 	ret
--- a/mpn/x86_64/bd1/popcount.asm	Fri Oct 28 16:31:44 2022 +0200
+++ b/mpn/x86_64/bd1/popcount.asm	Wed Nov 02 13:48:37 2022 +0100
@@ -167,7 +167,7 @@
 	paddq	%xmm5, %xmm8
 	pshufd	$14, %xmm8, %xmm0
 	paddq	%xmm8, %xmm0
-	movq	%xmm0, %rax
+	movd	%xmm0, %rax
 	add	%rdx, %rax
 	FUNC_EXIT()
 	ret
--- a/mpn/x86_64/core2/hamdist.asm	Fri Oct 28 16:31:44 2022 +0200
+++ b/mpn/x86_64/core2/hamdist.asm	Wed Nov 02 13:48:37 2022 +0100
@@ -191,7 +191,7 @@
 	paddq	%xmm4, %xmm8
 	pshufd	$14, %xmm8, %xmm0
 	paddq	%xmm8, %xmm0
-	movq	%xmm0, %rax
+	movd	%xmm0, %rax
 	ret
 EPILOGUE()
 DEF_OBJECT(L(cnsts),16,`JUMPTABSECT')
--- a/mpn/x86_64/core2/popcount.asm	Fri Oct 28 16:31:44 2022 +0200
+++ b/mpn/x86_64/core2/popcount.asm	Wed Nov 02 13:48:37 2022 +0100
@@ -166,7 +166,7 @@
 	paddq	%xmm4, %xmm8
 	pshufd	$14, %xmm8, %xmm0
 	paddq	%xmm8, %xmm0
-	movq	%xmm0, %rax
+	movd	%xmm0, %rax
 	ret
 EPILOGUE()
 DEF_OBJECT(L(cnsts),16,`JUMPTABSECT')
