class Termshare < Formula
  desc "Interactive or view-only terminal sharing via client or web"
  homepage "https://github.com/progrium/termshare"
  url "https://github.com/progrium/termshare/archive/v0.2.0.tar.gz"
  sha256 "fa09a5492d6176feff32bbcdb3b2dc3ff1b5ab2d1cf37572cc60eb22eb531dcd"

  head "https://github.com/progrium/termshare.git"

  bottle do
    sha1 "1189a998e33951ea6c5a4577b92d5b9090c1d2fe" => :mavericks
    sha1 "765981eef07f07a947cb31a4eaa17962ae945b21" => :mountain_lion
    sha1 "a7f5387d0e3595912dc45bd6f74811b2c4431d45" => :lion
  end

  depends_on "go" => :build
  depends_on :hg => :build

  def install
    ENV["GOPATH"] = buildpath

    # Install Go dependencies
    system "go", "get", "code.google.com/p/go.net/websocket"
    system "go", "get", "github.com/heroku/hk/term"
    system "go", "get", "github.com/kr/pty"
    system "go", "get", "github.com/nu7hatch/gouuid"

    # Build and install termshare
    system "go", "build", "-o", "termshare"
    bin.install "termshare"
  end

  test do
    system "#{bin}/termshare", "-v"
  end
end
