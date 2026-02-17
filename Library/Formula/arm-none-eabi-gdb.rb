class ArmNoneEabiGdb < Formula
  desc "GNU debugger for arm-none-eabi cross development"
  homepage "https://www.gnu.org/software/gdb/"
  url "https://ftp.gnu.org/gnu/gdb/gdb-14.2.tar.xz"
  mirror "https://ftpmirror.gnu.org/gdb/gdb-14.2.tar.xz"
  sha256 "2d4dd8061d8ded12b6c63f55e45344881e8226105f4d2a9b234040efa5ce7772"
  license "GPL-3.0-or-later"
  head "https://sourceware.org/git/binutils-gdb.git", branch: "master"

  bottle do
  end

  depends_on "gmp"
  depends_on "mpfr"
  depends_on "xz" # required for lzma support
  depends_on "zlib"
  depends_on "texinfo" => :build

  # Need compiler with C++11 support
  needs :cxx11

  def install
    target = "arm-none-eabi"
    args = %W[
      --target=#{target}
      --prefix=#{prefix}
      --datarootdir=#{share}/#{target}
      --includedir=#{include}/#{target}
      --infodir=#{info}/#{target}-gdb
      --mandir=#{man}
      --disable-debug
      --disable-dependency-tracking
      --with-lzma
      --with-system-zlib
      --disable-binutils
    ]

    mkdir "build" do
      system "../configure", *args
      ENV.deparallelize # Error: common/version.c-stamp.tmp: No such file or directory
      system "make"

      # Don't install bfd or opcodes, as they are provided by binutils
      system "make", "install-gdb"
    end
  end

  test do
    (testpath/"test.c").write "void _start(void) {}"
    system "#{Formula["arm-none-eabi-gcc"].bin}/arm-none-eabi-gcc", "-g", "-nostdlib", "test.c"
    assert_match "Symbol \"_start\" is a function at address 0x",
          shell_output("#{bin}/arm-none-eabi-gdb -batch -ex 'info address _start' a.out")
  end
end
