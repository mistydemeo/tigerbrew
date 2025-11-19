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

  # 4.0 doesn't support -Wvla -Wc++-compat
  # these are just enable diagnostic messages
  # so remove them
  patch :p1, :DATA

  depends_on "make" => :build
  depends_on "cctools" => :build

  def install
    ENV["AS"] = Formula["cctools"].bin/"as"
    system "gmake", "BACKTRACE=0"
    system "gmake", "install", "PREFIX=#{prefix}"
  end
end
__END__
diff --git a/lib/common/threading.c b/lib/common/threading.c
index 25bb8b9..7f630fa 100644
--- a/lib/common/threading.c
+++ b/lib/common/threading.c
@@ -18,7 +18,7 @@
 #include "threading.h"
 
 /* create fake symbol to avoid empty translation unit warning */
-int g_ZSTD_threading_useless_symbol;
+int g_ZSTD_threading_useless_symbol = 0;
 
 #if defined(ZSTD_MULTITHREAD) && defined(_WIN32)
 
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

