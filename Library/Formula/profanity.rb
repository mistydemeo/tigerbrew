class Profanity < Formula
  desc "Console based XMPP client"
  homepage "http://www.profanity.im/"
  url "http://www.profanity.im/profanity-0.4.6.tar.gz"
  sha256 "9672667e419958dd75d40cc0f253087ba1ae7df0c3c855eaa780831ad8282a9f"
  head "https://github.com/boothj5/profanity.git"


  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build
  depends_on "libstrophe"
  depends_on "glib"
  depends_on "openssl"
  depends_on "gnutls"
  depends_on "libotr" => :recommended
  depends_on "terminal-notifier" => :optional

  def install
    system "./bootstrap.sh"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "profanity", "-v"
  end
end
