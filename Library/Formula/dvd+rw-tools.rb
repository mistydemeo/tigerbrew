class DvdxrwTools < Formula
  desc "DVD+-RW/R tools"
  homepage "https://web.archive.org/web/20250511193202/https://fy.chalmers.se/~appro/linux/DVD+RW/"
  url "http://fy.chalmers.se/~appro/linux/DVD+RW/tools/dvd+rw-tools-7.1.tar.gz"
  sha256 "f8d60f822e914128bcbc5f64fbe3ed131cbff9045dca7e12c5b77b26edde72ca"

  # Respect $PREFIX
  patch :DATA

  def install
    bin.mkpath
    man1.mkpath
    system "make", "PREFIX=#{prefix}", "install"
  end
end

__END__
diff --git a/Makefile.m4 b/Makefile.m4
index a6a100b..bf7c041 100644
--- a/Makefile.m4
+++ b/Makefile.m4
@@ -30,8 +30,8 @@ LINK.o	=$(LINK.cc)
 # to install set-root-uid, `make BIN_MODE=04755 install'...
 BIN_MODE?=0755
 install:	dvd+rw-tools
-	install -o root -m $(BIN_MODE) $(CHAIN) /usr/bin
-	install -o root -m 0644 growisofs.1 /usr/share/man/man1
+	install -m $(BIN_MODE) $(CHAIN) $(PREFIX)/bin
+	install -m 0644 growisofs.1 $(PREFIX)/share/man/man1
 ])
 
 ifelse(OS,MINGW32,[
