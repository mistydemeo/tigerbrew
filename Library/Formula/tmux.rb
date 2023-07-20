class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/releases/download/3.2a/tmux-3.2a.tar.gz"
  sha256 "551553a4f82beaa8dadc9256800bcc284d7c000081e47aa6ecbb6ff36eacd05f"
  license "ISC"
  revision 1

  bottle do
    sha256 "28ffa21032715ab34a336d5b3b911031339a99c618c4ed209eea9fda0c9703a1" => :tiger_altivec
  end

  head do
    url "https://github.com/tmux/tmux.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  # Fix build on Tiger
  patch :DATA

  depends_on "pkg-config" => :build
  depends_on "libevent"

  def install
    system "sh", "autogen.sh" if build.head?

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
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
--- a/compat/daemon-darwin.c
+++ b/compat/daemon-darwin.c
@@ -49,7 +49,6 @@
 
 #include <mach/mach.h>
 
-#include <Availability.h>
 #include <unistd.h>
 
 void daemon_darwin(void);
--- a/osdep-darwin.c
+++ b/osdep-darwin.c
@@ -19,8 +19,6 @@
 #include <sys/types.h>
 #include <sys/sysctl.h>
 
-#include <Availability.h>
-#include <libproc.h>
 #include <stdlib.h>
 #include <string.h>
 #include <unistd.h>
@@ -71,6 +67,9 @@
 char *
 osdep_get_cwd(int fd)
 {
+	/* Tigerbrew: removed implementation that doesn't compile on Tiger.
+	 * This function isn't critical (used by pane_current_path only). */
+#if 0
	static char			wd[PATH_MAX];
	struct proc_vnodepathinfo	pathinfo;
	pid_t				pgrp;
@@ -85,6 +86,7 @@ osdep_get_cwd(int fd)
		strlcpy(wd, pathinfo.pvi_cdir.vip_path, sizeof wd);
		return (wd);
	}
+#endif
	return (NULL);
 }
 

