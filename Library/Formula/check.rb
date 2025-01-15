class Check < Formula
  desc "C unit testing framework"
  homepage "http://check.sourceforge.net/"
  url "https://github.com/libcheck/check/releases/download/0.15.2/check-0.15.2.tar.gz"
  sha256 "a8de4e0bacfb4d76dd1c618ded263523b53b85d92a146d8835eb1a52932fa20a"

  bottle do
    cellar :any
  end

  option :universal

  def install
    # https://trac.macports.org/ticket/58591
    ENV.append_to_cflags "-D__DARWIN_UNIX03" if MacOS.version < :leopard

    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
