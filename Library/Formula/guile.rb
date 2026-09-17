class Guile < Formula
  desc "GUILE: GNU Ubiquitous Intelligent Language for Extensions"
  homepage "https://www.gnu.org/software/guile/"
  url "http://ftpmirror.gnu.org/guile/guile-3.0.11.tar.xz"
  mirror "https://ftp.gnu.org/pub/gnu/guile/guile-3.0.11.tar.xz"
  sha256 "818c79d236657a7fa96fb364137cc7b41b3bdee0d65c6174ca03769559579460"
  license "LGPL-3.0-or-later"

  bottle do
  end

  resource "powerpc-bootstrap" do
    url "https://www.geeklan.co.uk/files/guile-3.0.11-bootstrap-tiger-powerpc.tar.gz"
    sha256 "fae9cb4f0eaebe0a35531b3d646a445d3a8cbc5bb03ae941301f0ebdd6cba113"
  end

  # GCC 14 complains about incompatible pointer types (char ** vs const char **)
  patch :p0, :DATA if MacOS.version == :tiger

  head do
    url "http://git.sv.gnu.org/r/guile.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "libtool" => :run
  depends_on "libffi"
  depends_on "libiconv"
  depends_on "libunistring"
  depends_on "bdw-gc"
  depends_on "gmp"
  depends_on "readline"

  def install
    # Build is set to use O1 and needs additional settings for building on big endian systems
    # beside it.
    ENV.no_optimization
    # I think these prebuild images are for MIPS
    rm Dir[buildpath/"prebuilt/32-bit-big-endian/ice-9/*.go"] if Hardware::CPU.type == :ppc

    # Stupid dance to prevent files ending up in buildpath/stage0/stage0...
    mv buildpath/"stage0", buildpath/"stage0-dis"
    mv buildpath/"stage1", buildpath/"stage1-dis"
    mv buildpath/"stage2", buildpath/"stage2-dis"
    # Save several days (not joking) on bootstrapping but using pre-built files
    resource("powerpc-bootstrap").stage buildpath if Hardware::CPU.type == :ppc
    mv buildpath/"stage0-dis/Makefile.am", buildpath/"stage0/Makefile.am"
    mv buildpath/"stage0-dis/Makefile.in", buildpath/"stage0/Makefile.in"
    mv buildpath/"stage1-dis/Makefile.am", buildpath/"stage1/Makefile.am"
    mv buildpath/"stage1-dis/Makefile.in", buildpath/"stage1/Makefile.in"
    mv buildpath/"stage2-dis/Makefile.am", buildpath/"stage2/Makefile.am"
    mv buildpath/"stage2-dis/Makefile.in", buildpath/"stage2/Makefile.in"

    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-libiconv-prefix=#{Formula["libiconv"].opt_prefix}",
                          "--with-libreadline-prefix=#{Formula["readline"].opt_prefix}",
                          "--with-libunistring-prefix=#{Formula["libunistring"].opt_prefix}",
                          "--with-libgmp-prefix=#{Formula["gmp"].opt_prefix}"
    # Need to bootstrap with different optimisation settings on 32bit build big endian systems
    system "make", "GUILE_OPTIMIZATIONS=-O1 -Oresolve-primitives -Ocps" if Hardware::CPU.type == :ppc
    system "make", "install"

    # A really messed up workaround required on OS X --mkhl
    Pathname.glob("#{lib}/*.dylib") do |dylib|
      lib.install_symlink dylib.basename => "#{dylib.basename(".dylib")}.so"
    end

    (share/"gdb/auto-load").install Dir["#{lib}/*-gdb.scm"]
  end

  test do
    hello = testpath/"hello.scm"
    hello.write <<-EOS.undent
    (display "Hello World")
    (newline)
    EOS

    ENV["GUILE_AUTO_COMPILE"] = "0"

    system bin/"guile", hello
  end
end
__END__
--- libguile/ports.c.orig	2025-12-28 11:42:57.000000000 +0000
+++ libguile/ports.c	2025-12-28 11:50:41.000000000 +0000
@@ -1895,7 +1895,7 @@
 
   /* FIXME: locking!  */
   scm_port_acquire_iconv_descriptors (port, &input_cd, NULL);
-  done = iconv (input_cd, &input, &input_left, &output, &output_left);
+  done = iconv (input_cd, (const char* *)&input, &input_left, &output, &output_left);
   scm_port_release_iconv_descriptors (port);
 
   if (done == (size_t) -1)
@@ -3166,7 +3166,7 @@
   size_t res;
 
   scm_port_acquire_iconv_descriptors (port, NULL, &output_cd);
-  res = iconv (output_cd, &input, &input_left, &output, &output_left);
+  res = iconv (output_cd, (const char* *)&input, &input_left, &output, &output_left);
   saved_errno = errno;
   /* Emit bytes needed to get back to initial state, if needed.  */
   iconv (output_cd, NULL, NULL, &output, &output_left);
@@ -3201,7 +3201,7 @@
       input = (char *) escape;
       input_left = encode_escape_sequence (ch, escape);
       scm_port_acquire_iconv_descriptors (port, NULL, &output_cd);
-      res = iconv (output_cd, &input, &input_left, &output, &output_left);
+      res = iconv (output_cd, (const char* *)&input, &input_left, &output, &output_left);
       saved_errno = errno;
       iconv (output_cd, NULL, NULL, &output, &output_left);
       scm_port_release_iconv_descriptors (port);
@@ -3212,7 +3212,7 @@
       input = (char *) substitute;
       input_left = 1;
       scm_port_acquire_iconv_descriptors (port, NULL, &output_cd);
-      res = iconv (output_cd, &input, &input_left, &output, &output_left);
+      res = iconv (output_cd, (const char* *)&input, &input_left, &output, &output_left);
       saved_errno = errno;
       iconv (output_cd, NULL, NULL, &output, &output_left);
       scm_port_release_iconv_descriptors (port);
@@ -3541,7 +3541,7 @@
 
     scm_port_acquire_iconv_descriptors (port, NULL, &output_cd);
     iconv (output_cd, NULL, NULL, &output, &output_len);
-    result = iconv (output_cd, &input, &input_len, &output, &output_len);
+    result = iconv (output_cd, (const char* *)&input, &input_len, &output, &output_len);
     iconv (output_cd, NULL, NULL, &output, &output_len);
     scm_port_release_iconv_descriptors (port);
 
