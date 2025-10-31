class Minicom < Formula
  desc "Menu-driven communications program"
  homepage "https://salsa.debian.org/minicom-team/minicom"
  url "https://salsa.debian.org/minicom-team/minicom/-/archive/2.8/minicom-2.8.tar.bz2"
  sha256 "38cea30913a20349326ff3f1763ee1512b7b41601c24f065f365e18e9db0beba"

  # no-format-truncation showed up in GCC 7.x
  patch :p0, :DATA

  def install
    # There is a silly bug in the Makefile where it forgets to link to iconv. Workaround below.
    ENV["LIBS"] = "-liconv"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"

    (prefix + "etc").mkdir
    (prefix + "var").mkdir
    (prefix + "etc/minirc.dfl").write "pu lock #{prefix}/var\npu escape-key Escape (Meta)\n"
  end

  def caveats; <<-EOS
Terminal Compatibility
======================
If minicom doesn't see the LANG variable, it will try to fallback to
make the layout more compatible, but uglier. Certain unsupported
encodings will completely render the UI useless, so if the UI looks
strange, try setting the following environment variable:

LANG="en_US.UTF-8"

Text Input Not Working
======================
Most development boards require Serial port setup -> Hardware Flow
Control to be set to "No" to input text.
    EOS
  end
end
__END__
--- configure.orig	2025-10-31 20:42:45.000000000 +0000
+++ configure	2025-10-31 20:42:58.000000000 +0000
@@ -11342,7 +11342,7 @@
 
 if test "x$ac_cv_c_compiler_gnu" = xyes
 then
-	CFLAGS="$CFLAGS -W -Wall -Wextra -std=gnu99 -fno-common -Wno-format-truncation"
+	CFLAGS="$CFLAGS -W -Wall -Wextra -std=gnu99 -fno-common"
 fi
 
 # this is a hack, if we need getopt_long we also need getopt
