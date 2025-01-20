class Gmp < Formula
  desc "GNU multiple precision arithmetic library"
  homepage "https://gmplib.org/"
  url "https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz"
  sha256 "a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898"
  revision 1

  bottle do
  end

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

    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"
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

    # Test the static library to catch potential linking issues
    system ENV.cc, "test.c", "#{lib}/libgmp.a", "-o", "test"
    system "./test"
  end
end
