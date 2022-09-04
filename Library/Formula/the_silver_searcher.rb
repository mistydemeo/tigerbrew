class TheSilverSearcher < Formula
  desc "Code-search similar to ack"
  homepage "https://github.com/ggreer/the_silver_searcher"
  url "https://github.com/ggreer/the_silver_searcher/archive/0.33.0.tar.gz"
  sha256 "351ab79ada811fd08f81296de10a7498ea3c46b681d73696d5a2911edbdc19db"
  head "https://github.com/ggreer/the_silver_searcher.git"

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  depends_on "pkg-config" => :build
  depends_on "pcre"
  depends_on "xz"

  patch :DATA

  def install
    # Stable tarball does not include pre-generated configure script
    system "aclocal", "-I #{HOMEBREW_PREFIX}/share/aclocal"
    system "autoconf"
    system "autoheader"
    system "automake", "--add-missing"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"

    bash_completion.install "ag.bashcomp.sh"
  end

  test do
    (testpath/"Hello.txt").write("Hello World!")
    system "#{bin}/ag", "Hello World!", testpath
  end
end
__END__
diff --git a/src/main.c b/src/main.c
index 4259b60..3cd78d9 100644
--- a/src/main.c
+++ b/src/main.c
@@ -8,6 +8,10 @@
 #ifdef _WIN32
 #include <windows.h>
 #endif
+#if __APPLE__
+#include <sys/types.h>
+#include <sys/sysctl.h>
+#endif
 
 #include "config.h"
 
@@ -69,6 +73,15 @@ int main(int argc, char **argv) {
         GetSystemInfo(&si);
         num_cores = si.dwNumberOfProcessors;
     }
+#elif __APPLE__
+    {
+        /* Tiger fix */
+        size_t num_cores_len = sizeof(num_cores);
+        int sysctl_rc = sysctlbyname("hw.ncpu", &num_cores, &num_cores_len, NULL, 0);
+        if (0 != sysctl_rc) {
+            num_cores = 1; /* assume 1 CPU if sysctlbyname fails */
+        }
+    }
 #else
     num_cores = (int)sysconf(_SC_NPROCESSORS_ONLN);
 #endif

