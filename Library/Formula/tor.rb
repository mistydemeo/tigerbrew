class Tor < Formula
  desc "Anonymizing overlay network for TCP"
  homepage "https://www.torproject.org/"
  url "https://dist.torproject.org/tor-0.4.7.13.tar.gz"
  mirror "https://tor.eff.org/dist/tor-0.4.7.13.tar.gz"
  sha256 "2079172cce034556f110048e26083ce9bea751f3154b0ad2809751815b11ea9d"

  bottle do
    sha256 "10215ccde70597d6bb8efdad496de4b76991aae838a66ffcbb0f1ca033da786c" => :el_capitan
    sha256 "acf689a5cf4ac59116b04cc271d999aea16d6dac44d8dce3b873a9ac0f854433" => :yosemite
    sha256 "b6e02ebdbc250b0beb199e55135d9514e88b3c195f442931ef8528bb9de8680c" => :mavericks
    sha256 "6e4085a67f555cb0b34b74818fb4f43dcc353d653100633aefa85804148f5d5e" => :mountain_lion
  end

  depends_on "libevent"
  depends_on "openssl"
  depends_on "zlib"
  depends_on "libnatpmp" => :optional
  depends_on "miniupnpc" => :optional
  depends_on "libscrypt" => :optional

  def install
    # Revert commit to replace GCC comments with __attribute__((fallthrough)) macro
    # https://gitlab.torproject.org/tpo/core/tor/-/commit/c116728209e4ece3249564208e9387f67192a7f6.patch
    inreplace "src/core/or/reasons.c", "FALLTHROUGH;", "/* fall through */"
    inreplace "src/core/or/scheduler.c", "FALLTHROUGH;", "/* fall through */"
    inreplace "src/core/or/sendme.c", "FALLTHROUGH;", "/* Fall through because default is to use v0. */"
    inreplace "src/feature/control/control_cmd.c", "FALLTHROUGH;", "/* fall through */"
    inreplace "src/app/config/quiet_level.c", "FALLTHROUGH;", "/* fall through */"
    inreplace "src/lib/crypt_ops/crypto_digest_openssl.c", "FALLTHROUGH;", "/* fall through */"
    inreplace "src/test/test_socks.c", "FALLTHROUGH;", "/* fall through */"

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --with-openssl-dir=#{Formula["openssl"].opt_prefix}
      --with-zlib=#{Formula["zlib"].opt_prefix}
    ]

    args << "--with-libnatpmp-dir=#{Formula["libnatpmp"].opt_prefix}" if build.with? "libnatpmp"
    args << "--with-libminiupnpc-dir=#{Formula["miniupnpc"].opt_prefix}" if build.with? "miniupnpc"
    args << "--disable-libscrypt" if build.without? "libscrypt"

    system "./configure", *args
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    You will find a sample `torrc` file in #{etc}/tor.
    It is advisable to edit the sample `torrc` to suit
    your own security needs:
      https://www.torproject.org/docs/faq#torrc
    After editing the `torrc` you need to restart tor.
    EOS
  end

  test do
    system bin/"tor", "--version"
  end

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
        <true/>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/tor</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/tor.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/tor.log</string>
      </dict>
    </plist>
    EOS
  end
end
