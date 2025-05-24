class Help2man < Formula
  desc "Automatically generate simple man pages"
  homepage "https://www.gnu.org/software/help2man/"
  url "http://ftpmirror.gnu.org/help2man/help2man-1.47.2.tar.xz"
  mirror "https://ftp.gnu.org/gnu/help2man/help2man-1.47.2.tar.xz"
  sha256 "c4c5606773e51039a06b7328ed4934913df142747a9a185d2a6ab9300d7f3f7c"


  def install
    # install is not parallel safe
    # see https://github.com/Homebrew/homebrew/issues/12609
    ENV.j1

    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    cmd = "#{bin}/help2man #{bin}/help2man"
    assert_match(/"help2man #{version}"/, shell_output(cmd))
  end
end
