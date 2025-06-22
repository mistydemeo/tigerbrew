class Tinyproxy < Formula
  desc "HTTP/HTTPS proxy for POSIX systems"
  homepage "https://web.archive.org/web/20151221033441/https://www.banu.com/tinyproxy/"
  url "https://www.banu.com/pub/tinyproxy/1.8/tinyproxy-1.8.3.tar.bz2"
  sha256 "be559b54eb4772a703ad35239d1cb59d32f7cf8a739966742622d57df88b896e"

  bottle do
    revision 1
    sha256 "c38d434bfc1c9b1f659a1c2275872c288b13dbf4f9300adc07a39e836e0f15f7" => :yosemite
    sha256 "97fc5062add3375191da067af89b6e9ddd3c5a306c3feffad4c821e532a9ef2f" => :mavericks
    sha256 "ced9b61ab07ac9dbc0e89a8763c6506e7ebb1309bf709400be9643025d64e63b" => :mountain_lion
  end

  depends_on "asciidoc" => :build

  option "with-reverse", "Enable reverse proxying"
  option "with-transparent", "Enable transparent proxying"

  deprecated_option "reverse" => "with-reverse"

  # Fix linking error, via MacPorts: https://trac.macports.org/ticket/27762
  patch :p0 do
    url "https://trac.macports.org/export/83413/trunk/dports/net/tinyproxy/files/patch-configure.diff"
    sha256 "414b8ae7d0944fb8d90bef708864c4634ce1576c5f89dd79539bce1f630c9c8d"
  end

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --localstatedir=#{var}
      --sysconfdir=#{etc}
      --disable-regexcheck
    ]

    args << "--enable-reverse" if build.with? "reverse"
    args << "--enable-transparent" if build.with? "transparent"

    system "./configure", *args

    # Fix broken XML lint
    # See: https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=154624
    inreplace ["docs/man5/Makefile", "docs/man8/Makefile"] do |s|
      s.gsub! "-f manpage", "-f manpage \\\n  -L"
    end

    system "make", "install"
  end

  def post_install
    (var/"log/tinyproxy").mkpath
    (var/"run/tinyproxy").mkpath
  end

  test do
    pid = fork do
      exec "#{sbin}/tinyproxy"
    end
    sleep 2

    begin
      assert_match /tinyproxy/, shell_output("curl localhost:8888")
    ensure
      Process.kill("SIGINT", pid)
      Process.wait(pid)
    end
  end

  plist_options :manual => "tinyproxy"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_sbin}/tinyproxy</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
    EOS
  end
end
