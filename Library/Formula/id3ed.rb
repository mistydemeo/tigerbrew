class Id3ed < Formula
  desc "ID3 tag editor for MP3 files"
  homepage "https://web.archive.org/web/20230604094705/http://code.fluffytapeworm.com/projects/id3ed"
  url "https://web.archive.org/web/20230604094705/http://code.fluffytapeworm.com/projects/id3ed/id3ed-1.10.4.tar.gz"
  sha256 "56f26dfde7b6357c5ad22644c2a379f25fce82a200264b5d4ce62f2468d8431b"

  bottle do
    cellar :any
    sha256 "2ed5fd5dbb117a28776090fb80aa0b147bb7027372b49584d21ec1741ec3faeb" => :tiger_altivec
  end

  # Make sure we link to our readline
  patch :p0, :DATA

  depends_on "readline"

  def install
    # Need to find libhistory
    ENV.append "CXXFLAGS", "-L#{Formula["readline"].lib}"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--bindir=#{bin}/",
                          "--mandir=#{man1}"
    bin.mkpath
    man1.mkpath
    system "make", "install"
  end

  test do
    system "#{bin}/id3ed", "-r", "-q", test_fixtures("test.mp3")
  end
end
__END__
--- configure.orig	2024-03-23 18:27:47.000000000 +0000
+++ configure	2024-03-23 18:28:53.000000000 +0000
@@ -926,7 +926,7 @@
   echo $ac_n "(cached) $ac_c" 1>&6
 else
   ac_save_LIBS="$LIBS"
-LIBS="-lhistory  $LIBS"
+LIBS="$LIB -lhistory"
 cat > conftest.$ac_ext <<EOF
 #line 932 "configure"
 #include "confdefs.h"
@@ -963,7 +963,7 @@
 #define $ac_tr_lib 1
 EOF
 
-  LIBS="-lhistory $LIBS"
+  LIBS="$LIBS -lhistory"
 
 else
   echo "$ac_t""no" 1>&6
