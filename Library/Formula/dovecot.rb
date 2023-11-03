class Dovecot < Formula
  desc "IMAP/POP3 server"
  homepage "http://dovecot.org/"
  url "https://dovecot.org/releases/2.3/dovecot-2.3.21.tar.gz"
  mirror "https://fossies.org/linux/misc/dovecot-2.3.21.tar.gz"
  sha256 "05b11093a71c237c2ef309ad587510721cc93bbee6828251549fc1586c36502d"

  bottle do
    sha256 "5a844e280812b18bef1cef8139bd7fb191f0ec1c83e8b010b1d093c063546c4f" => :tiger_altivec
  end

  depends_on "bzip2"
  depends_on "lz4"
  depends_on "openssl3"
  depends_on "xz"
  depends_on "zlib"
  depends_on "clucene" => :optional

  def install
    # Need unsetenv(3) to return int, not void
    ENV.append_to_cflags "-D__DARWIN_UNIX03" if MacOS.version == :tiger
    # dovecot expect newer support from kqueue which Leopard and Tiger lack.
    # disable ioloop & notify kqueue support otherwise dovect will fail to run.
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --libexecdir=#{libexec}
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --with-ssl=openssl
      --with-sqlite
      --with-zlib
      --with-bzlib
      --with-ioloop=none
      --with-notify=none
      --with-pam
    ]

    args << "--with-lucene" if build.with? "clucene"

    system "./configure",  *args
    system "make", "install"
  end

  plist_options :startup => true

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>KeepAlive</key>
        <false/>
        <key>RunAtLoad</key>
        <true/>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_sbin}/dovecot</string>
          <string>-F</string>
        </array>
        <key>StandardErrorPath</key>
        <string>#{var}/log/dovecot/dovecot.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/dovecot/dovecot.log</string>
      </dict>
    </plist>
    EOS
  end

  def caveats; <<-EOS.undent
    For Dovecot to work, you may need to create a dovecot user
    and group depending on your configuration file options.
    EOS
  end

  test do
    assert_match /#{version}/, shell_output("#{sbin}/dovecot --version")
  end

  # .data & .used are members of a union, nested in struct buffer
  # lib/compat.h: add ST_?TIME_SEC() macros
  # https://github.com/dovecot/core/commit/3294f9074a1c6f2b64f956a21dea3b8b51b33aaf
  # dbox: dbox_mailbox_open() - use ST_?TIME_SEC() macros
  # https://github.com/dovecot/core/commit/0a6198c690c063f05934b4981793e1ddb7ca24b3
  patch :p0, :DATA
end
__END__
--- ./src/lib-smtp/test-smtp-params.c.orig	2023-07-21 15:11:25.000000000 +0100
+++ ./src/lib-smtp/test-smtp-params.c	2023-07-21 15:16:23.000000000 +0100
@@ -26,12 +26,12 @@
 };
 
 static struct buffer test_params_buffer1 = {
-	.data = (void*)&test_params1,
-	.used = sizeof(test_params1)
+	{{ .data = (void*)&test_params1,
+	.used = sizeof(test_params1) }}
 };
 static struct buffer test_params_buffer2 = {
-	.data = (void*)&test_params2,
-	.used = sizeof(test_params2)
+	{{ .data = (void*)&test_params2,
+	.used = sizeof(test_params2) }}
 };
 
 /* Valid mail params tests */
--- src/lib/compat.h
+++ src/lib/compat.h
@@ -56,15 +56,24 @@ typedef unsigned long long uoff_t;
 #  define ST_ATIME_NSEC(st) ((unsigned long)(st).st_atim.tv_nsec)
 #  define ST_MTIME_NSEC(st) ((unsigned long)(st).st_mtim.tv_nsec)
 #  define ST_CTIME_NSEC(st) ((unsigned long)(st).st_ctim.tv_nsec)
+#  define ST_ATIME_SEC(st) ((unsigned long)(st).st_atim.tv_sec)
+#  define ST_MTIME_SEC(st) ((unsigned long)(st).st_mtim.tv_sec)
+#  define ST_CTIME_SEC(st) ((unsigned long)(st).st_ctim.tv_sec)
 #elif defined (HAVE_STAT_XTIMESPEC)
 #  define HAVE_ST_NSECS
 #  define ST_ATIME_NSEC(st) ((unsigned long)(st).st_atimespec.tv_nsec)
 #  define ST_MTIME_NSEC(st) ((unsigned long)(st).st_mtimespec.tv_nsec)
 #  define ST_CTIME_NSEC(st) ((unsigned long)(st).st_ctimespec.tv_nsec)
+#  define ST_ATIME_SEC(st) ((unsigned long)(st).st_atimespec.tv_sec)
+#  define ST_MTIME_SEC(st) ((unsigned long)(st).st_mtimespec.tv_sec)
+#  define ST_CTIME_SEC(st) ((unsigned long)(st).st_ctimespec.tv_sec)
 #else
 #  define ST_ATIME_NSEC(st) 0UL
 #  define ST_MTIME_NSEC(st) 0UL
 #  define ST_CTIME_NSEC(st) 0UL
+#  define ST_ATIME_SEC(st) 0UL
+#  define ST_MTIME_SEC(st) 0UL
+#  define ST_CTIME_SEC(st) 0UL
 #endif
 
 #ifdef HAVE_ST_NSECS
--- src/lib-storage/index/dbox-common/dbox-storage.c
+++ src/lib-storage/index/dbox-common/dbox-storage.c
@@ -305,8 +305,8 @@ int dbox_mailbox_list_cleanup(struct mail_user *user, const char *path,
 		   if the directory exists. In case, get also the ctime */
 		struct stat stats;
 		if (stat(path, &stats) == 0) {
-			last_temp_file_scan = stats.st_atim.tv_sec;
-			change_time = stats.st_ctim.tv_sec;
+			last_temp_file_scan = ST_ATIME_SEC(stats);
+			change_time = ST_CTIME_SEC(stats);
 		} else {
 			if (errno != ENOENT)
 				e_error(user->event, "stat(%s) failed: %m", path);
