class Beanstalk < Formula
  desc "Generic work queue originally designed to reduce web latency"
  homepage "https://kr.github.io/beanstalkd/"
  url "https://github.com/kr/beanstalkd/archive/v1.10.tar.gz"
  sha256 "923b1e195e168c2a91adcc75371231c26dcf23868ed3e0403cd4b1d662a52d59"


  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  plist_options :manual => "beanstalkd"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/beanstalkd</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/beanstalkd.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/beanstalkd.log</string>
      </dict>
    </plist>
    EOS
  end
end
