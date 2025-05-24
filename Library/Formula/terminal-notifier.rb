class TerminalNotifier < Formula
  desc "Send OS X User Notifications from the command-line"
  homepage "https://github.com/alloy/terminal-notifier"
  url "https://github.com/alloy/terminal-notifier/archive/1.6.3.tar.gz"
  sha256 "d71243e194d290e873eb5c5f30904e1d9406246d089e7d4d48ca275a8abfe275"

  head "https://github.com/alloy/terminal-notifier.git"


  depends_on :macos => :mountain_lion
  depends_on :xcode => :build

  def install
    xcodebuild "-project", "Terminal Notifier.xcodeproj",
               "-target", "terminal-notifier",
               "SYMROOT=build",
               "-verbose"
    prefix.install Dir["build/Release/*"]
    inner_binary = "#{prefix}/terminal-notifier.app/Contents/MacOS/terminal-notifier"
    bin.write_exec_script inner_binary
    chmod 0755, bin/"terminal-notifier"
  end

  test do
    system "#{bin}/terminal-notifier", "-help" if MacOS.version < :yosemite
  end
end
