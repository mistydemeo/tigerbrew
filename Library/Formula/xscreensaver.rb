class Xscreensaver < Formula
  desc "Standard collection of screen savers found on most Linux and Unix systems."
  homepage "https://www.jwz.org/xscreensaver"
  url "https://github.com/ablakely/xscreensaver-ppc/archive/refs/tags/v1.0a.tar.gz"
  sha256 "3a46cac321df736f73b99184ae54efec794a06bc68707e85e42fa319e8d0597c"
  version "5.14"

  def install
    system "make", "install"
    system "open", "-b", "com.apple.systempreferences", "/System/Library/PreferencePanes/DesktopScreenEffectsPref.prefPane"
  end
end
