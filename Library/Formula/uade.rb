class Uade < Formula
  desc "Play Amiga tunes through UAE emulation"
  homepage "https://zakalwe.fi/uade/"

  stable do
    url "http://zakalwe.fi/uade/uade2/uade-2.13.tar.bz2"
    sha256 "3b194e5aebbfa99d3708d5a0b5e6bd7dc5d1caaecf4ae9b52f8ff87e222dd612"

    # Upstream patch to fix compiler detection under superenv
    patch :DATA
  end

  head "git://zakalwe.fi/uade"

  depends_on "pkg-config" => :build
  depends_on "libao"

  resource "bencode-tools" do
    url "https://github.com/heikkiorsila/bencode-tools.git"
  end

  def install
    resource("bencode-tools").stage do
      system "./configure", "--prefix=#{prefix}", "--without-python"
      system "make"
      system "make", "install"
    end if build.head?

    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end
end

__END__
diff --git a/configure b/configure
index 05bfa9b..a73608e 100755
--- a/configure
+++ b/configure
@@ -399,13 +399,13 @@ if test -n "$sharedir"; then
     uadedatadir="$sharedir"
 fi
 
-$NATIVECC -v 2>/dev/null >/dev/null
+$NATIVECC --version 2>/dev/null >/dev/null
 if test "$?" != "0"; then
     echo Native CC "$NATIVECC" not found, please install a C compiler
     exit 1
 fi
 
-$TARGETCC -v 2>/dev/null >/dev/null
+$TARGETCC --version 2>/dev/null >/dev/null
 if test "$?" != "0"; then
     echo Target CC "$TARGETCC" not found, please install a C compiler
     exit 1
