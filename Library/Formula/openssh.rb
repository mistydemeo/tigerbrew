class Openssh < Formula
  desc "OpenBSD freely-licensed SSH connectivity tools"
  homepage "https://www.openssh.com/"
  url "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.1p1.tar.gz"
  mirror "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.1p1.tar.gz"
  version "10.1p1"
  sha256 "b9fc7a2b82579467a6f2f43e4a81c8e1dfda614ddb4f9b255aafd7020bbf0758"
  license "SSH-OpenSSH"

  bottle do
  end

  # Please don't resubmit the keychain patch option. It will never be accepted.
  # https://archive.is/hSB6d#10%25

  # clock_gettime(3) showed up in Sierra
  # https://marc.info/?l=openssh-unix-dev&m=175935977710302&w=2
  patch :DATA

  depends_on "pkg-config" => :build
  depends_on "ldns"
  depends_on "openssl3"
  depends_on "zlib"

  def install
    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}/ssh
      --with-ldns
      --with-libedit
      --with-kerberos5
      --with-pam
      --with-ssl-dir=#{Formula["openssl3"].opt_prefix}
      --with-zlib=#{Formula["zlib"].opt_prefix}
    ]

    system "./configure", *args
    system "make"
    ENV.deparallelize
    system "make", "install"

    # This was removed by upstream with very little announcement and has
    # potential to break scripts, so recreate it for now.
    # Debian have done the same thing.
    bin.install_symlink bin/"ssh" => "slogin"
  end

  def caveats; <<-EOS.undent
    In order to be able to use sshd, you need to enable PAM support by stating
    UsePAM yes
    in your #{etc}/ssh/sshd_config
    EOS
  end

  test do
    require "socket"
    def free_port
      server = TCPServer.new 0
      _, port, = server.addr
      server.close
      port
    end

    assert_match "OpenSSH_", shell_output("#{bin}/ssh -V 2>&1")

    port = free_port
    fork { exec sbin/"sshd", "-D", "-p", port.to_s }
    sleep 2
    assert_match "sshd", shell_output("lsof -i :#{port}")
  end
end
__END__
diff --git a/openbsd-compat/bsd-misc.c b/openbsd-compat/bsd-misc.c
index 983cd3fe6..2c196ec23 100644
--- a/openbsd-compat/bsd-misc.c
+++ b/openbsd-compat/bsd-misc.c
@@ -494,6 +494,30 @@ localtime_r(const time_t *timep, struct tm *result)
 }
 #endif
 
+#ifndef HAVE_CLOCK_GETTIME
+int
+clock_gettime(clockid_t clockid, struct timespec *ts)
+{
+	struct timeval tv;
+
+	if (clockid != CLOCK_REALTIME) {
+		errno = ENOSYS;
+		return -1;
+	}
+	if (ts == NULL) {
+		errno = EFAULT;
+		return -1;
+	}
+
+	if (gettimeofday(&tv, NULL) == -1)
+		return -1;
+
+	ts->tv_sec = tv.tv_sec;
+	ts->tv_nsec = (long)tv.tv_usec * 1000;
+	return 0;
+}
+#endif
+
 #ifdef ASAN_OPTIONS
 const char *__asan_default_options(void) {
 	return ASAN_OPTIONS;
diff --git a/openbsd-compat/bsd-misc.h b/openbsd-compat/bsd-misc.h
index 2ad89cd83..8495f471c 100644
--- a/openbsd-compat/bsd-misc.h
+++ b/openbsd-compat/bsd-misc.h
@@ -202,6 +202,14 @@ int flock(int, int);
 struct tm *localtime_r(const time_t *, struct tm *);
 #endif
 
+#ifndef HAVE_CLOCK_GETTIME
+typedef int clockid_t;
+#ifndef CLOCK_REALTIME
+# define CLOCK_REALTIME	0
+#endif
+int clock_gettime(clockid_t, struct timespec *);
+#endif
+
 #ifndef HAVE_REALPATH
 #define realpath(x, y)	(sftp_realpath((x), (y)))
 #endif
