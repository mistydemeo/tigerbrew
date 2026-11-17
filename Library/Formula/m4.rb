class M4 < Formula
  desc "Macro processing language"
  homepage "https://www.gnu.org/software/m4"
  url "https://ftpmirror.gnu.org/m4/m4-1.4.21.tar.xz"
  mirror "https://ftp.gnu.org/gnu/m4/m4-1.4.21.tar.xz"
  sha256 "f25c6ab51548a73a75558742fb031e0625d6485fe5f9155949d6486a2408ab66"
  license "GPL-3.0-or-later"

  bottle do
  end

  keg_only :provided_by_osx

  # Skip the gnulib tests as they have their own set of problems which has nothing to do with what's being built.
  patch :p0, :DATA

  option "with-tests", "Build and run the test suite"

  # sigsegv.c: In function 'sigsegv_handler':
  # sigsegv.c:938: error: 'struct mcontext' has no member named '__ss'
  depends_on "libsigsegv" if MacOS.version == :tiger

  def install
    args = [
      "--disable-dependency-tracking",
      "--prefix=#{prefix}",
    ]

    args << "--with-libsigsegv" if MacOS.version == :tiger
    args << "--with-libsigsegv-prefix=#{Formula["libsigsegv"].opt_prefix}" if MacOS.version == :tiger

    system "./configure", *args
    system "make"
    system "make", "check" if build.with?("tests") || build.bottle?
    system "make", "install"
  end

  test do
    assert_match "Homebrew",
      pipe_output("#{bin}/m4", "define(TEST, Homebrew)\nTEST\n")
  end
end
__END__
--- Makefile.in.orig	2026-11-16 19:47:43.000000000 +0000
+++ Makefile.in	2026-11-16 19:47:57.000000000 +0000
@@ -2484,7 +2484,7 @@
 top_build_prefix = @top_build_prefix@
 top_builddir = @top_builddir@
 top_srcdir = @top_srcdir@
-SUBDIRS = . examples lib src doc checks po tests
+SUBDIRS = . examples lib src doc checks po
 EXTRA_DIST = bootstrap c-boxes.el cfg.mk maint.mk \
 	.prev-version .version m4/gnulib-cache.m4 ChangeLog-2014
 
