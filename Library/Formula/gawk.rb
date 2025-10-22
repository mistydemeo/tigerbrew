class Gawk < Formula
  desc "GNU awk utility"
  homepage "https://www.gnu.org/software/gawk/"
  url "http://ftpmirror.gnu.org/gawk/gawk-5.3.2.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gawk/gawk-5.3.2.tar.xz"
  sha256 "f8c3486509de705192138b00ef2c00bbbdd0e84c30d5c07d23fc73a9dc4cc9cc"

  bottle do
  end

  # spawn.h containing posix_spawnattr_* functions showed up in Leopard
  patch :p0, :DATA

  depends_on "mpfr"
  depends_on "readline"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-readline",
                          "--with-mpfr"
    system "make"
    system "make", "install"
  end

  test do
    output = pipe_output("#{bin}/gawk '{ gsub(/Macro/, \"Home\"); print }' -", "Macrobrew")
    assert_equal "Homebrew", output.strip
  end
end
__END__
--- posix/gawkmisc.c.orig	2025-10-10 20:04:02.000000000 +0100
+++ posix/gawkmisc.c	2025-10-10 20:05:43.000000000 +0100
@@ -341,7 +341,7 @@
 			(void) unsetenv("GAWK_PMA_REINCARNATION");
 	}
 #endif
-#ifdef HAVE__NSGETEXECUTABLEPATH
+#if defined(HAVE__NSGETEXECUTABLEPATH) && defined(HAVE_SPAWN_H)
 	// This code is for macos
 	if (persist_file != NULL) {
 		const char *cp = getenv("GAWK_PMA_REINCARNATION");
