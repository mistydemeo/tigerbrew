class Distcc < Formula
  desc "Distributed compiler client and server"
  homepage "https://www.distcc.org/"
  url "https://github.com/distcc/distcc/releases/download/v3.4/distcc-3.4.tar.gz"
  sha256 "2b99edda9dad9dbf283933a02eace6de7423fe5650daa4a728c950e5cd37bd7d"
  license "GPL-2.0-or-later"

  # Python 3.10+ compatibility
  patch do
  url "https://github.com/distcc/distcc/commit/83e030a852daf1d4d8c906e46f86375d421b781e.patch?full_index=1"
  sha256 "d65097b7c13191e18699d3a9c7c9df5566bba100f8da84088aa4e49acf46b6a7"
  end

  depends_on "python3"

  def install
    # libiberty flag can be dropped in the next release. Enable IPv6 support.
    system "./configure", "--prefix=#{prefix}", "--without-libiberty", "--enable-rfc2553"
    system "make", "install"
    plist_path.write startup_plist
    plist_path.chmod 0644
  end

  def startup_plist; <<-EOPLIST.undent
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
            <string>#{HOMEBREW_PREFIX}/bin/distccd</string>
            <string>--daemon</string>
            <string>--no-detach</string>
            <string>--allow=192.168.0.1/24</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
    EOPLIST
  end

  def caveats; <<-EOS.undent
    Use 'brew services start distcc' to start distccd automatically on login.
    By default, it will allow access to all clients on 192.168.0.1/24.
    EOS
  end

  test do
    system "#{bin}/distcc", "--version"

    (testpath/"Makefile").write <<~MAKE
      default:
      	@echo Tigerbrew
    MAKE
    assert_match "distcc hosts list does not contain any hosts", shell_output("#{bin}/pump make 2>&1", 1)

    ENV["DISTCC_POTENTIAL_HOSTS"] = "localhost"
    assert_match "Tigerbrew\n", shell_output("#{bin}/pump make")
  end
end
