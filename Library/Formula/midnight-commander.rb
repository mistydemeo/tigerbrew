class MidnightCommander < Formula
  desc "Terminal-based visual file manager"
  homepage "https://www.midnight-commander.org/"
  url "http://ftp.midnight-commander.org/mc-4.8.30.tar.xz"
  mirror "https://ftp.osuosl.org/pub/midnightcommander/mc-4.8.30.tar.xz"
  sha256 "5ebc3cb2144b970c5149fda556c4ad50b78780494696cdf2d14a53204c95c7df"

  head "https://github.com/MidnightCommander/mc.git"

  bottle do
  end

  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "openssl3"
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
