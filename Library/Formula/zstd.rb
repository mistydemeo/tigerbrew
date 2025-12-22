class Zstd < Formula
  desc "Zstd"
  homepage "https://www.zstd.net"
  url "https://github.com/facebook/zstd/releases/download/v1.5.7/zstd-1.5.7.tar.gz"
  sha256 "eb33e51f49a15e023950cd7825ca74a4a2b43db8354825ac24fc1b7ee09e6fa3"
  license all_of: [
    { any_of: ["BSD-3-Clause", "GPL-2.0-only"] },
    "BSD-2-Clause", # programs/zstdgrep, lib/libzstd.pc.in
    "MIT", # lib/dictBuilder/divsufsort.c
  ]

  bottle do
    cellar :any
    sha256 "62e611b9d7e61516e11361dd8d1f4e13a503b6cf6a8d6a5cb714dd360d88a48b" => :tiger_g3
  end

  # GCC 4.0 doesn't support -Wvla -Wc++-compat warnings
  # -compatibility_version only allowed with -dynamiclib
  # ld: common symbols not allowed with MH_DYLIB output format with the -multi_module option
  patch :p1, :DATA

  depends_on "make" => :build
  depends_on "lz4"
  depends_on "xz"
  depends_on "zlib"

  def install
    # libtool: unknown option character `w' in: -w
    ENV.enable_warnings if ENV.compiler == :gcc_4_0

    # as doesn't recognise --noexecstack
    system "gmake", "ALREADY_APPENDED_NOEXECSTACK=1"
    system "gmake", "install", "PREFIX=#{prefix}"
  end

  test do
    data = "Hello, Tigerbrew"
    assert_equal data, pipe_output("#{bin}/zstd -d", pipe_output("#{bin}/zstd", data))
    ["xz", "lz4", "gzip"].each do |prog|
      assert_equal data, pipe_output("#{prog} -d", pipe_output("#{bin}/zstd --format=#{prog}", data))
    end
  end
end
__END__
diff --git a/lib/libzstd.mk b/lib/libzstd.mk
index 91bd4ca..a7d13dc 100644
--- a/lib/libzstd.mk
+++ b/lib/libzstd.mk
@@ -113,8 +113,8 @@ endif
 DEBUGFLAGS= -Wall -Wextra -Wcast-qual -Wcast-align -Wshadow \
             -Wstrict-aliasing=1 -Wswitch-enum -Wdeclaration-after-statement \
             -Wstrict-prototypes -Wundef -Wpointer-arith \
-            -Wvla -Wformat=2 -Winit-self -Wfloat-equal -Wwrite-strings \
-            -Wredundant-decls -Wmissing-prototypes -Wc++-compat
+            -Wformat=2 -Winit-self -Wfloat-equal -Wwrite-strings \
+            -Wredundant-decls -Wmissing-prototypes
 CFLAGS   += $(DEBUGFLAGS) $(MOREFLAGS)
 ASFLAGS  += $(DEBUGFLAGS) $(MOREFLAGS) $(CFLAGS)
 LDFLAGS  += $(MOREFLAGS)

--- a/lib/Makefile
+++ b/lib/Makefile
@@ -79,7 +79,7 @@
   SHARED_EXT = dylib
   SHARED_EXT_MAJOR = $(LIBVER_MAJOR).$(SHARED_EXT)
   SHARED_EXT_VER = $(LIBVER).$(SHARED_EXT)
-  SONAME_FLAGS = -install_name $(LIBDIR)/libzstd.$(SHARED_EXT_MAJOR) -compatibility_version $(LIBVER_MAJOR) -current_version $(LIBVER)
+  SONAME_FLAGS = -install_name $(LIBDIR)/libzstd.$(SHARED_EXT_MAJOR) -compatibility_version $(LIBVER_MAJOR) -current_version $(LIBVER) -dynamiclib
 else
   ifeq ($(UNAME_TARGET_SYSTEM), AIX)
     SONAME_FLAGS =
@@ -144,7 +144,7 @@
 LIBZSTD = libzstd.$(SHARED_EXT_VER)
 .PHONY: $(LIBZSTD)  # must be run every time
 $(LIBZSTD): CPPFLAGS += $(CPPFLAGS_DYNLIB)
-$(LIBZSTD): CFLAGS   += -fPIC -fvisibility=hidden
+$(LIBZSTD): CFLAGS   += -fPIC -fvisibility=hidden -fno-common
 $(LIBZSTD): LDFLAGS  += -shared $(LDFLAGS_DYNLIB)
 
 ifndef BUILD_DIR
