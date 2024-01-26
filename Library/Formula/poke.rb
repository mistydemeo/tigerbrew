class Poke < Formula
  desc "Extensible editor for structured binary data"
  homepage "https://jemarch.net/poke"
  url "https://ftp.gnu.org/gnu/poke/poke-3.3.tar.gz"
  sha256 "0080459de85063c83b689ffcfba36872236803c12242d245a42ee793594f956e"
  license "GPL-3.0-or-later"

  bottle do
    sha256 "86730dc40a621d8c16d31d9de0501744962949c2a5c427d3f217d82c9f3164de" => :tiger_altivec
  end

  # MAP_ANONYMOUS is not defined on Leopard and Tiger
  patch :p0, :DATA

  depends_on "pkg-config" => :build
  depends_on "bdw-gc"
  depends_on "gettext"
  depends_on "libiconv"
  depends_on "ncurses"
  depends_on "readline"

  # ../../libpoke/pvm.jitter:6829: error: #pragma GCC diagnostic not allowed inside functions
  fails_with :gcc do
    build 5553
    cause "One test failure on G4"
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-silent-rules
      --with-lispdir=#{share}/emacs/site-lisp/#{name}
      --with-libncurses-prefix=#{Formula["ncurses"].opt_prefix}
      --with-libreadline-prefix=#{Formula["readline"].opt_prefix}
      --with-libiconv-prefix=#{Formula["libiconv"].opt_prefix}
    ]
    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.pk").write <<~EOS
      .file #{bin}/poke
      dump :size 4#B :ruler 0 :ascii 0
      .exit
    EOS
    if Hardware::CPU.type == :intel
      assert_match "00000000: cffa edfe", shell_output("#{bin}/poke --quiet -s test.pk")
    elsif Hardware::CPU.type == :ppc
      assert_match "00000000: feed face", shell_output("#{bin}/poke --quiet -s test.pk")
    end
  end
end
__END__
--- jitter/jitter/jitter-aligned-block.c.orig	2023-07-31 22:30:11.000000000 +0100
+++ jitter/jitter/jitter-aligned-block.c	2023-07-31 22:31:57.000000000 +0100
@@ -37,6 +37,9 @@
 # error "no aligned block implementation defined.  This should never happen."
 #endif
 
+#if defined (JITTER_ALIGNED_BLOCK_USE_MMAP) && !defined (MAP_ANONYMOUS)
+#define MAP_ANONYMOUS   MAP_ANON
+#endif
 
 
 
--- jitter/jitter/jitter-stack.c.orig	2023-07-31 22:35:44.000000000 +0100
+++ jitter/jitter/jitter-stack.c	2023-07-31 22:37:08.000000000 +0100
@@ -28,6 +28,10 @@
 # include <sys/mman.h>
 #endif
 
+#if defined (JITTER_HAVE_MMAP_ANONYMOUS) && !defined (MAP_ANONYMOUS)
+#define MAP_ANONYMOUS   MAP_ANON
+#endif
+
 #include <jitter/jitter-bitwise.h>
 #include <jitter/jitter-fatal.h>
 #include <jitter/jitter-stack.h>
