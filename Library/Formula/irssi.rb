class Irssi < Formula
  desc "Modular IRC client"
  homepage "http://irssi.org/"
  url "https://codeberg.org/irssi/irssi/releases/download/1.4.4/irssi-1.4.4.tar.xz"
  sha256 "fefe9ec8c7b1475449945c934a2360ab12693454892be47a6d288c63eb107ead"
  revision 1

  head do
    url "https://github.com/irssi/irssi.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
    depends_on "lynx" => :build
  end

  bottle do
    sha256 "9cd240467cb01ccd6ecda35bf7b216ea85ebbc1674f02c3a747c0a36c2b7f1db" => :tiger_altivec
  end

  # Fix crash on exit with Tiger.
  # realpath(3) changed in POSIX.1-2008 however the signature is
  # the same so we can use it without guarding to OS version.
  # https://github.com/irssi/irssi/issues/1482
  patch :p0, :DATA

  option "with-dante", "Build with SOCKS support"
  option "without-perl", "Build without perl support"

  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "openssl3"
  depends_on "dante" => :optional
  depends_on "ncurses"
  depends_on "perl" if build.with? "perl"

  if build.with? "perl"
    # Bug building with Perl 5.37 & newer
    # https://github.com/irssi/irssi/pull/1474
    patch do
      url "https://patch-diff.githubusercontent.com/raw/irssi/irssi/pull/1474.patch"
      sha256 "ca09a9e64f0fb304ed309addbf8dbbeba76e3309b403a274de4ce59302d51ee8"
    end
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --with-proxy
      --enable-true-color
      --with-socks=#{build.with?("dante") ? "yes" : "no"}
    ]

    if build.with? "perl"
      args << "--with-perl=yes"
      args << "--with-perl-lib=#{lib}/perl5/site_perl"
    else
      args << "--with-perl=no"
    end

    # confuses Perl library path configuration
    # https://github.com/Homebrew/homebrew/issues/34685
    ENV.delete "PERL_MM_OPT"

    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    # "make" and "make install" must be done separately on some systems
    system "make"
    system "make", "install"
  end

  test do
    IO.popen("#{bin}/irssi --connect=irc.freenode.net", "w") do |pipe|
      pipe.puts "/quit\n"
      pipe.close_write
    end
  end
end
__END__
--- src/lib-config/write.c.orig	2023-07-27 12:22:36.000000000 +0100
+++ src/lib-config/write.c	2023-07-27 12:27:33.000000000 +0100
@@ -312,16 +312,13 @@
 
 	base_name = fname != NULL ? fname : rec->fname;
 
-	/* expand all symlinks; else we may replace a symlink with a regular file */
-	dest_name = realpath(base_name, NULL);
-
-	if (errno == EINVAL) {
-		/* variable path length not supported by glibc < 2.3, Solaris < 11 */
-		char resolved_path[PATH_MAX] = { 0 };
-		errno = 0;
-		if ((dest_name = realpath(base_name, resolved_path)) != NULL) {
-			dest_name = g_strdup(dest_name);
-		}
+	/* expand all symlinks; else we may replace a symlink with a regular file.
+	   Variable path length not supported by glibc < 2.3, Solaris < 11,
+           Mac OS X < 10.5 */
+	char resolved_path[PATH_MAX] = { 0 };
+	errno = 0;
+	if ((dest_name = realpath(base_name, resolved_path)) != NULL) {
+		dest_name = g_strdup(dest_name);
 	}
 
 	if (dest_name == NULL) {
