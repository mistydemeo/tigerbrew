class Lighttpd < Formula
  desc "Small memory footprint, flexible web-server"
  homepage "http://www.lighttpd.net/"
  url "https://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-1.4.73.tar.xz"
  sha256 "818816d0b314b0aa8728a7076513435f6d5eb227f3b61323468e1f10dbe84ca8"

  bottle do
    sha256 "7252a8fe2a2eb25011d5bbba22bb385fbafce92c52d9b036618cae037d80b830" => :tiger_altivec
  end

  option "with-lua51", "Include Lua scripting support for mod_magnet"

  # provide STAILQ_FOREACH
  # https://github.com/litespeedtech/ls-hpack/pull/13
  patch :p0, :DATA

  depends_on "pkg-config" => :build
  depends_on "pcre2"
  depends_on "openssl3"
  depends_on "xxhash"
  depends_on "lua51" => :optional

  # default max. file descriptors; this option will be ignored if the server is not started as root
  MAX_FDS = 512

  def config_path
    etc+"lighttpd"
  end

  def log_path
    var+"log/lighttpd"
  end

  def www_path
    var+"www"
  end

  def run_path
    var+"lighttpd"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --sbindir=#{bin}
      --with-openssl
      --with-zlib
      --with-xxhash
    ]

    args << "--with-lua" if build.with? "lua51"

    system "./configure", *args
    system "make", "install"

    unless File.exist? config_path
      config_path.install "doc/config/lighttpd.conf", "doc/config/modules.conf"
      (config_path/"conf.d/").install Dir["doc/config/conf.d/*.conf"]
      inreplace config_path+"lighttpd.conf" do |s|
        s.sub!(/^var\.log_root\s*=\s*".+"$/, "var.log_root    = \"#{log_path}\"")
        s.sub!(/^var\.server_root\s*=\s*".+"$/, "var.server_root = \"#{www_path}\"")
        s.sub!(/^var\.state_dir\s*=\s*".+"$/, "var.state_dir   = \"#{run_path}\"")
        s.sub!(/^var\.home_dir\s*=\s*".+"$/, "var.home_dir    = \"#{run_path}\"")
        s.sub!(/^var\.conf_dir\s*=\s*".+"$/, "var.conf_dir    = \"#{config_path}\"")
        s.sub!(/^server\.port\s*=\s*80$/, "server.port = 8080")
        s.sub!(%r{^server\.document-root\s*=\s*server_root \+ "\/htdocs"$}, "server.document-root = server_root")

        s.sub!(/^server\.username\s*=\s*".+"$/, 'server.username  = "_www"')
        s.sub!(/^server\.groupname\s*=\s*".+"$/, 'server.groupname = "_www"')
        s.sub!(/^#server\.event-handler\s*=\s*"linux-sysepoll"$/, 'server.event-handler = "kqueue"')
        s.sub!(/^#server\.network-backend\s*=\s*"sendfile"$/, 'server.network-backend = "writev"')

        # "max-connections == max-fds/2",
        # http://redmine.lighttpd.net/projects/1/wiki/Server_max-connectionsDetails
        s.sub!(/^#server\.max-connections = .+$/, "server.max-connections = " + (MAX_FDS / 2).to_s)
      end
    end

    log_path.mkpath
    (www_path/"htdocs").mkpath
    run_path.mkpath
  end

  def caveats; <<-EOS.undent
    Docroot is: #{www_path}

    The default port has been set in #{config_path}lighttpd.conf to 8080 so that
    lighttpd can run without sudo.
    EOS
  end

  test do
    system "#{bin}/lighttpd", "-t", "-f", config_path+"lighttpd.conf"
  end

  plist_options :manual => "lighttpd -f #{HOMEBREW_PREFIX}/etc/lighttpd/lighttpd.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/lighttpd</string>
        <string>-D</string>
        <string>-f</string>
        <string>#{config_path}/lighttpd.conf</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <false/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{log_path}/output.log</string>
      <key>StandardOutPath</key>
      <string>#{log_path}/output.log</string>
      <key>HardResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>#{MAX_FDS}</integer>
      </dict>
      <key>SoftResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>#{MAX_FDS}</integer>
      </dict>
    </dict>
    </plist>
    EOS
  end

end
__END__
--- src/ls-hpack/lshpack.h.orig	2023-08-08 17:05:52.000000000 +0100
+++ src/ls-hpack/lshpack.h	2023-08-08 17:06:32.000000000 +0100
@@ -237,6 +237,13 @@
 #define STAILQ_FOREACH          SIMPLEQ_FOREACH
 #endif
 
+#ifndef STAILQ_FOREACH
+#define STAILQ_FOREACH(var, head, field)                                \
+        for((var) = STAILQ_FIRST((head));                               \
+           (var);                                                       \
+           (var) = STAILQ_NEXT((var), field))
+#endif
+
 struct lshpack_enc_table_entry;
 
 STAILQ_HEAD(lshpack_enc_head, lshpack_enc_table_entry);
