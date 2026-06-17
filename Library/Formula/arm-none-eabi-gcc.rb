class ArmNoneEabiGcc < Formula
  desc "GNU compiler collection for arm-none-eabi"
  homepage "https://gcc.gnu.org"
  url "https://ftp.gnu.org/gnu/gcc/gcc-13.4.0/gcc-13.4.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-13.4.0/gcc-13.4.0.tar.xz"
  sha256 "9c4ce6dbb040568fdc545588ac03c5cbc95a8dbf0c7aa490170843afb59ca8f5"
  license "GPL-3.0-or-later" => { with: "GCC-exception-3.1" }

  bottle do
  end

  depends_on "arm-none-eabi-binutils"
  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mpfr"
  depends_on "zlib"
  depends_on "ld64" => :build if MacOS.version < :leopard
  depends_on "texinfo" => :build

  # Need a compiler with C++11 support
  needs :cxx11

  def install
    # Build breaks with optimisation enabled.
    ENV.no_optimization if Hardware::CPU.type == :ppc

    target = "arm-none-eabi"
    mkdir "arm-none-eabi-gcc-build" do
      system "../configure", "--target=#{target}",
                             "--prefix=#{prefix}",
                             "--infodir=#{info}/#{target}-gcc",
                             "--disable-nls",
                             "--without-isl",
                             "--without-headers",
                             "--with-system-zlib",
                             "--with-pkgversion=Tigerbrew #{name} #{pkg_version} #{build.used_options*" "}".strip,
                             "--with-bugurl=https://github.com/mistydemeo/tigerbrew/issues",
                             "--with-as=#{Formula["arm-none-eabi-binutils"].bin}/arm-none-eabi-as",
                             "--with-ld=#{Formula["arm-none-eabi-binutils"].bin}/arm-none-eabi-ld",
                             "--enable-languages=c,c++"

       system "make", "all-gcc"
       system "make", "install-gcc"
       system "make", "all-target-libgcc"
       system "make", "install-target-libgcc"

      # FSF-related man pages may conflict with native gcc
      (share/"man/man7").rmtree
    end
  end

  test do
    (testpath/"test-c.c").write <<~EOS
      int main(void)
      {
        int i=0;
        while(i<10) i++;
        return i;
      }
    EOS
    system "#{bin}/arm-none-eabi-gcc", "-c", "-o", "test-c.o", "test-c.c"
    assert_match "file format elf32-littlearm",
                 shell_output("#{Formula["arm-none-eabi-binutils"].bin}/arm-none-eabi-objdump -a test-c.o")
  end
end
