class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/releases/download/3.5a/tmux-3.5a.tar.gz"
  sha256 "16216bd0877170dfcc64157085ba9013610b12b082548c7c9542cc0103198951"
  license "ISC"
  revision 1

  bottle do
    cellar :any
  end

  head do
    url "https://github.com/tmux/tmux.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  # Use MAC_OS_X_VERSION_MIN_REQUIRED macro for OS version guards
  # https://github.com/tmux/tmux/pull/4550
  patch :DATA

  depends_on "pkg-config" => :build
  depends_on "libevent"
  depends_on "utf8proc"

  def install
    system "sh", "autogen.sh" if build.head?

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --enable-utf8proc
    ]

    ENV.append "LDFLAGS", "-lresolv"
    system "./configure", *args

    system "make", "install"

    pkgshare.install "example_tmux.conf"
  end

  def caveats; <<-EOS.undent
    Example configuration has been installed to:
      #{pkgshare}
    EOS
  end

  test do
    system "#{bin}/tmux", "-V"
  end
end
__END__
diff --git a/compat/daemon-darwin.c b/compat/daemon-darwin.c
index 64400206..d7202509 100644
--- a/compat/daemon-darwin.c
+++ b/compat/daemon-darwin.c
@@ -49,12 +49,12 @@
 
 #include <mach/mach.h>
 
-#include <Availability.h>
+#include <AvailabilityMacros.h>
 #include <unistd.h>
 
 void daemon_darwin(void);
 
-#ifdef __MAC_10_10
+#if MAC_OS_X_VERSION_MIN_REQUIRED >= 101000
 
 extern kern_return_t	bootstrap_look_up_per_user(mach_port_t, const char *,
 			    uid_t, mach_port_t *);
diff --git a/osdep-darwin.c b/osdep-darwin.c
index a2b125ad..ad66c53c 100644
--- a/osdep-darwin.c
+++ b/osdep-darwin.c
@@ -19,11 +19,14 @@
 #include <sys/types.h>
 #include <sys/sysctl.h>
 
-#include <Availability.h>
+#include <AvailabilityMacros.h>
+#if MAC_OS_X_VERSION_MIN_REQUIRED >= 1050
 #include <libproc.h>
+#endif
 #include <stdlib.h>
 #include <string.h>
 #include <unistd.h>
+#include <sys/cdefs.h>
 
 #include "compat.h"
 
@@ -31,14 +34,10 @@ char			*osdep_get_name(int, char *);
 char			*osdep_get_cwd(int);
 struct event_base	*osdep_event_init(void);
 
-#ifndef __unused
-#define __unused __attribute__ ((__unused__))
-#endif
-
 char *
 osdep_get_name(int fd, __unused char *tty)
 {
-#ifdef __MAC_10_7
+#if MAC_OS_X_VERSION_MIN_REQUIRED >= 1070
 	struct proc_bsdshortinfo	bsdinfo;
 	pid_t				pgrp;
 	int				ret;
@@ -72,6 +71,7 @@ osdep_get_name(int fd, __unused char *tty)
 char *
 osdep_get_cwd(int fd)
 {
+#if MAC_OS_X_VERSION_MIN_REQUIRED >= 1050
 	static char			wd[PATH_MAX];
 	struct proc_vnodepathinfo	pathinfo;
 	pid_t				pgrp;
@@ -86,6 +86,7 @@ osdep_get_cwd(int fd)
 		strlcpy(wd, pathinfo.pvi_cdir.vip_path, sizeof wd);
 		return (wd);
 	}
+#endif
 	return (NULL);
 }
 
