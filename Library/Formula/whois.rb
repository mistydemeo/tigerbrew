class Whois < Formula
  desc "Lookup tool for domain names and other internet resources"
  homepage "https://github.com/rfc1036/whois"
  url "https://ftp.debian.org/debian/pool/main/w/whois/whois_5.5.20.tar.xz"
  sha256 "42085102dfad82067abe2d5d1cfca59586573dee528718559b022e762bb85cf1"
  license "GPL-2.0-or-later"

  bottle do
    cellar :any
    sha256 "a40ae5a6fd644ca1156466e8401dfa7f75a9dbfac90385688ab2f89541e210a0" => :tiger_altivec
  end

  keg_only :provided_by_osx

  depends_on "make" => :build
  depends_on "perl" => :build
  depends_on "pkg-config" => :build
  depends_on "bash-completion"
  depends_on "libidn2"
  depends_on "libxcrypt"

  # Attribute was introduced in GCC 11
  patch :p0, :DATA

  def install
    ENV.append "LDFLAGS", "-L/usr/lib -liconv"
    ENV.append_to_cflags "-std=gnu99"

    system "gmake", "install", "prefix=#{prefix}"
  end

  test do
    system "#{bin}/whois", "brew.sh"
  end
end
__END__
--- utils.h.orig	2023-11-23 15:17:08.000000000 +0000
+++ utils.h	2023-11-23 15:17:23.000000000 +0000
@@ -24,7 +24,7 @@
 # define NONNULL
 # define UNUSED
 #endif
-#if defined __GNUC__ && !defined __clang__
+#if (defined __GNUC__ && __GNUC__ >= 11) && !defined __clang__
 # define MALLOC_FREE __attribute__((malloc(free)))
 #else
 # define MALLOC_FREE
