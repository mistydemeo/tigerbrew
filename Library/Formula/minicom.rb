class Minicom < Formula
  desc "Menu-driven communications program"
  homepage "https://salsa.debian.org/minicom-team/minicom"
  url "https://salsa.debian.org/minicom-team/minicom/-/archive/2.10/minicom-2.10.tar.bz2"
  sha256 "90e7ce2856b3eaaa3f452354d17981c49d32c426a255b6f0d3063a227c101538"

  # no-format-truncation showed up in GCC 7.x
  # Revert to using strncpy(3), _Static_assert() is a C11 feature.
  # https://salsa.debian.org/minicom-team/minicom/-/commit/01d1bfdd83e407042cc401ea4477a9e30adc830b
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
--- src/dial.c.orig	2025-11-02 18:28:07.000000000 +0000
+++ src/dial.c	2025-11-02 18:29:42.000000000 +0000
@@ -754,9 +754,7 @@
     return 1;
 
   memcpy(d->username, v1.username, sizeof(v1) - offsetof(struct v1_dialent, username));
-  _Static_assert(sizeof(d->name) >= sizeof(v1.name), "Size mismatch");
-  v1.name[sizeof(v1.name) - 1] = 0;
-  strcpy(d->name, v1.name);
+  strncpy(d->name, v1.name, sizeof(d->name));
   d->name[sizeof(d->name) - 1] = '\0';
   strncpy(d->number, v1.number, sizeof(d->number));
   d->number[sizeof(d->number) - 1] = '\0';
--- src/updown.c.orig	2025-11-02 18:28:17.000000000 +0000
+++ src/updown.c	2025-11-02 18:31:44.000000000 +0000
@@ -384,8 +384,8 @@
             trim (trimbuf, buf, sizeof(trimbuf));
             do_log("%s", trimbuf);
           } else if (!strncmp (buffirst, "Bytes", 5)) {
-            _Static_assert(sizeof(xfrstr) >= sizeof(buf), "String sizes");
-            strcpy(xfrstr, buf);
+            strncpy (xfrstr, buf, sizeof(xfrstr));
+            xfrstr[sizeof(xfrstr) - 1] = '\0';
           }
           buffirst[0] = 0;
           trimbuf[0] = 0;
