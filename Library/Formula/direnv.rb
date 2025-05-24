class Direnv < Formula
  desc "Load/unload environment variables based on $PWD"
  homepage "http://direnv.net"
  url "https://github.com/zimbatm/direnv/archive/v2.7.0.tar.gz"
  sha256 "3cfa8f41e740c0dc09d854f3833058caec0ea0d67d19e950f97eee61106b0daf"

  head "https://github.com/zimbatm/direnv.git"


  depends_on "go" => :build

  def install
    system "make", "install", "DESTDIR=#{prefix}"
  end

  def caveats
    "Finish setup by following: https://github.com/zimbatm/direnv#setup"
  end

  test do
    system bin/"direnv", "status"
  end
end
