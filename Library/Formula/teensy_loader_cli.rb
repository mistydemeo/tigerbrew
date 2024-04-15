class TeensyLoaderCli < Formula
  desc "Command-line integration for Teensy USB development boards"
  homepage "https://www.pjrc.com/teensy/loader_cli.html"
  url "https://github.com/PaulStoffregen/teensy_loader_cli/archive/refs/tags/2.2.tar.gz"
  sha256 "103c691f412d04906c4f46038c234d3e5f78322c1b78ded102df9f900724cd54"

  depends_on "make"
  depends_on "libusb"

  # Be flexible about where libusb can be found
  patch :p0, :DATA

  def install
    system "gmake", "USE_LIBUSB=YES", "OS=MACOSX"
    bin.install "teensy_loader_cli"
  end

  test do
    output = shell_output("#{bin}/teensy_loader_cli 2>&1", 1)
    assert_match "Filename must be specified", output
  end
end
__END__
--- Makefile.orig	2024-04-15 22:32:01.000000000 +0100
+++ Makefile	2024-04-15 22:32:29.000000000 +0100
@@ -27,7 +27,7 @@
 CC ?= gcc
 CFLAGS ?= -O2 -Wall
 teensy_loader_cli: teensy_loader_cli.c
-	$(CC) $(CFLAGS) -s -DUSE_LIBUSB -DMACOSX -o teensy_loader_cli teensy_loader_cli.c -lusb -I /usr/local/include -L/usr/local/lib
+	$(CC) $(CFLAGS) -s -DUSE_LIBUSB -DMACOSX -o teensy_loader_cli teensy_loader_cli.c -lusb $(LDFLAGS)
 	 
 else
 CC ?= gcc
