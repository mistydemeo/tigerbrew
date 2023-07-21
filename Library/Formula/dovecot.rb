class Dovecot < Formula
  desc "IMAP/POP3 server"
  homepage "http://dovecot.org/"
  url "https://dovecot.org/releases/2.3/dovecot-2.3.20.tar.gz"
  mirror "https://fossies.org/linux/misc/dovecot-2.3.20.tar.gz"
  sha256 "caa832eb968148abdf35ee9d0f534b779fa732c0ce4a913d9ab8c3469b218552"

  depends_on "openssl"
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
