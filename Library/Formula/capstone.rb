class Capstone < Formula
  desc "Multi-platform, multi-architecture disassembly framework"
  homepage "https://www.capstone-engine.org/"
  url "https://github.com/capstone-engine/capstone/archive/refs/tags/5.0.3.tar.gz"
  sha256 "3970c63ca1f8755f2c8e69b41432b710ff634f1b45ee4e5351defec4ec8e1753"
  license "BSD-3-Clause"
  head "https://github.com/capstone-engine/capstone.git", branch: "next"

  bottle do
    cellar :any
    sha256 "009d483c0a578917986d26bfb08a77b9a350c2dd3ac36842fdbfa8a93c881eca" => :tiger_altivec
    sha256 "02f9a9eb65e16eef186973cbdf6f0a6a79afd45a7245993d1c6c4b12dee0bcc6" => :tiger_g3
  end

  # error: #pragma GCC diagnostic not allowed inside functions
  fails_with :gcc if MacOS.version < :leopard

  # Fix OS detection
  patch :p0, :DATA

  depends_on "make"

  def install
    # ENV.no_optimization
    ENV["HOMEBREW_CAPSTONE"] = "1"
    ENV["PREFIX"] = prefix
    ENV["MAKE"] = "gmake"
    ENV["LIBARCHS"] = "ppc" if Hardware::CPU.type == :ppc
    ENV["LIBARCHS"] = "i386" if Hardware::CPU.type == :intel
    system "./make.sh"
    system "gmake", "install", "PREFIX=#{prefix}"
  end

  test do
    # code comes from https://www.capstone-engine.org/lang_c.html
    (testpath/"test.c").write <<-EOS.undent
      #include <stdio.h>
      #include <inttypes.h>
      #include <capstone/capstone.h>
      #define CODE "\\x55\\x48\\x8b\\x05\\xb8\\x13\\x00\\x00"

      int main()
      {
        csh handle;
        cs_insn *insn;
        size_t count;
        if (cs_open(CS_ARCH_X86, CS_MODE_64, &handle) != CS_ERR_OK)
          return -1;
        count = cs_disasm(handle, CODE, sizeof(CODE)-1, 0x1000, 0, &insn);
        if (count > 0) {
          size_t j;
          for (j = 0; j < count; j++) {
            printf("0x%"PRIx64":\\t%s\\t\\t%s\\n", insn[j].address, insn[j].mnemonic,insn[j].op_str);
          }
          cs_free(insn, count);
        } else
          printf("ERROR: Failed to disassemble given code!\\n");
        cs_close(&handle);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lcapstone", "-o", "test"
    system "./test"
  end
end
__END__
--- Makefile.orig	2024-02-03 01:12:02.000000000 +0000
+++ Makefile	2024-02-03 01:18:32.000000000 +0000
@@ -344,7 +344,7 @@
 API_MAJOR=$(shell echo `grep -e CS_API_MAJOR include/capstone/capstone.h | grep -v = | awk '{print $$3}'` | awk '{print $$1}')
 VERSION_EXT =
 
-IS_APPLE := $(shell $(CC) -dM -E - < /dev/null 2> /dev/null | grep __apple_build_version__ | wc -l | tr -d " ")
+IS_APPLE := $(shell $(CC) -dM -E - < /dev/null 2> /dev/null | grep __APPLE__ | wc -l | tr -d " ")
 ifeq ($(IS_APPLE),1)
 # on MacOS, do not build in Universal format by default
 MACOS_UNIVERSAL ?= no
