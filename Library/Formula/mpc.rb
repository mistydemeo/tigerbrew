class Mpc < Formula
  desc "Command-line music player client for mpd"
  homepage "http://www.musicpd.org/clients/mpc/"
  url "http://www.musicpd.org/download/mpc/0/mpc-0.27.tar.gz"
  sha256 "07113c71a21cbd0ea028273baa8e35f23f2a76b94a5c37e16927fdc7c6934463"


  depends_on "pkg-config" => :build
  depends_on "libmpdclient"

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"
    system "make", "install"
  end
end
