class Hexcmp < Formula
  desc "Compare two Intel HEX files"
  homepage "https://web.archive.org/web/20031116002446/http://members.naspa.net/djs/software/hexcmp.html"
  url "https://web.archive.org/web/20031116002446/http://members.naspa.net/djs/software/hexcmp-0.2.tar.gz"
  sha256 "43c4b4cfd51561bfaf9e069e70e48110ebf269b9e18286054d3fd6c6e0b9bfb9"

  # warning: pointer targets in passing argument { 1, 2 } of ‘bytecmp’ differ in signedness
  # Allow build flags to be appended/overriden
  patch :p0, :DATA

  def install
    system "make", "-C", "hexcmp-0.2",  "static"
    bin.install "hexcmp-0.2/hexcmp"
  end

  test do
    file1 = testpath/"file1.hex"
    file1.write <<-EOS.undent
      :020000040000FA
      :020000000528D1
      :00000001FF
    EOS

    file2 = testpath/"file2.hex"
    file2.write <<-EOS.undent
      :020000040000FA
      :00000001FF
    EOS

    assert shell_output("#{bin}/hexcmp #{file1} #{file2}", 1 ).include? "#{file1} and #{file2} differ at memory address 0h."
  end
end
__END__
--- hexcmp-0.2/hexcmp.c.orig	2025-08-23 19:12:09.000000000 +0100
+++ hexcmp-0.2/hexcmp.c	2025-08-23 19:12:36.000000000 +0100
@@ -34,7 +34,7 @@
  * Return first byte that differs between two buffers, or else -1 if buffers
  * are the same.
  */
-int bytecmp(const char *b1, const char *b2, int n)
+int bytecmp(const unsigned char *b1, const unsigned char *b2, int n)
 {
 	int i;
 	
--- hexcmp-0.2/Makefile.orig	2025-08-23 19:13:22.000000000 +0100
+++ hexcmp-0.2/Makefile	2025-08-23 19:14:03.000000000 +0100
@@ -1,6 +1,6 @@
-CC=gcc
-CFLAGS=-c -Wall
-LDFLAGS=-lhexfile
+CC?=gcc
+CFLAGS+=-c -Wall
+LDFLAGS+=-lhexfile
 
 all: hexcmp
 
