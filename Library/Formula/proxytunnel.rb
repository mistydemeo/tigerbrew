class Proxytunnel < Formula
  desc "Create TCP tunnels through HTTPS proxies"
  homepage "http://proxytunnel.sourceforge.net/"
  url "https://downloads.sourceforge.net/proxytunnel/proxytunnel-1.9.0.tgz"
  sha256 "2ef5bbf8d81ddf291d71f865c5dab89affcc07c4cb4b3c3f23e1e9462721a6b9"
  revision 1


  depends_on "openssl"

  # Remove conflicting strlcpy/strlcat declarations
  patch :DATA

  def install
    system "make"
    bin.install "proxytunnel"
    man1.install "proxytunnel.1"
  end
end

__END__
diff --git a/Makefile b/Makefile
index 9e9ac73..8244b55 100644
--- a/Makefile
+++ b/Makefile
@@ -56,8 +56,6 @@ PROGNAME = proxytunnel
 # Remove strlcpy/strlcat on (open)bsd/darwin systems
 OBJ = proxytunnel.o	\
 	base64.o	\
-	strlcpy.o	\
-	strlcat.o	\
 	strzcat.o	\
 	setproctitle.o	\
 	io.o		\
diff --git a/proxytunnel.h b/proxytunnel.h
index b948be0..e63c72a 100644
--- a/proxytunnel.h
+++ b/proxytunnel.h
@@ -32,8 +32,6 @@ void closeall();
 void do_daemon();
 void initsetproctitle(int argc, char *argv[]);
 void setproctitle(const char *fmt, ...);
-size_t strlcat(char *dst, const char *src, size_t siz);
-size_t strlcpy(char *dst, const char *src, size_t siz);
 size_t strzcat(char *dst, char *format, ...);
 int main( int argc, char *argv[] );
 char * readpassphrase(const char *, char *, size_t, int);
