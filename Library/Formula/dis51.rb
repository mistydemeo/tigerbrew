class Dis51 < Formula
  desc "Intel 8051 (MCS-51) Hex-file Disassembler"
  homepage "https://plit.de/asem-51/dis51.html"
  url "https://plit.de/asem-51/dis51-0.5.tar.gz"
  sha256 "a6241f142324bb175ed94a663b2caec53e06943320ef6e127015746e13c9a4f6"

  # Allow build flags to be appended/overriden
  patch :p0, :DATA

  def install
    system "make"
    bin.install "dis51"
  end

  test do
    path = testpath/"end.hex"
    path.write <<-EOS.undent
      :00000001FF
    EOS

    assert_match "END", pipe_output("/bin/cat #{path} | #{bin}/dis51")
  end
end
__END__
--- Makefile.orig	2025-08-23 14:49:51.000000000 +0100
+++ Makefile	2025-08-23 14:50:43.000000000 +0100
@@ -1,6 +1,6 @@
-CC=gcc
-CFLAGS=-c -I. -Wall
-LDFLAGS=
+CC?=gcc
+CFLAGS+=-c -I. -Wall
+LDFLAGS?=
 SHAREDLDFLAGS=-lhexfile
 
 OBJECTS=main.o pass1.o pass2.o global.o
