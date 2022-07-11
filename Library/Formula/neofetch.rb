class Neofetch < Formula
  desc "A CLI system information tool written in BASH"
  homepage "https://github.com/dylanaraps/neofetch"
  url "https://github.com/dylanaraps/neofetch/archive/refs/tags/7.1.0.tar.gz"
  sha256 "58a95e6b714e41efc804eca389a223309169b2def35e57fa934482a6b47c27e7"
  version "7.1.0"

  patch do
    url "https://gist.githubusercontent.com/ablakely/69b1c2c563209e6790a0feddd6b56e70/raw/974c4a6cd35241dcc29b670fb22651021bd8eb76/patch"
    sha256 "bf0adb97068915400147c18dc9e0f6955ac74cf9e38e1ab7f97dd0b599ea6f50"
  end

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end
end
