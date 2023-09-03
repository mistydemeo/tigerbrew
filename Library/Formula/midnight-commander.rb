class MidnightCommander < Formula
  desc "Terminal-based visual file manager"
  homepage "https://www.midnight-commander.org/"
  url "http://ftp.midnight-commander.org/mc-4.8.29.tar.xz"
  mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/m/mc/mc_4.8.29.orig.tar.xz"
  sha256 "01d8a3b94f58180cca5bf17257b5078d1fd6fd27a9b5c0e970ec767549540ad4"

  head "https://github.com/MidnightCommander/mc.git"

  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "openssl"
  depends_on "s-lang"
  depends_on "libssh2"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--without-x",
                          "--with-screen=slang",
                          "--enable-vfs-sftp"
    system "make", "install"
  end

  test do
    assert_match "GNU Midnight Commander", shell_output("#{bin}/mc --version")
  end
end
