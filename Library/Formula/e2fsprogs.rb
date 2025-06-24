class E2fsprogs < Formula
  desc "Utilities for the ext2, ext3, and ext4 file systems"
  homepage "http://e2fsprogs.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.42.13/e2fsprogs-1.42.13.tar.gz"
  mirror "https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.42.13/e2fsprogs-1.42.13.tar.gz"
  sha256 "59993ff3a44f82e504561e0ebf95e8c8fa9f9f5746eb6a7182239605d2a4e2d4"

  head "https://git.kernel.org/pub/scm/fs/ext2/e2fsprogs.git"


  keg_only "This brew installs several commands which override OS X-provided file system commands."

  depends_on "pkg-config" => :build
  depends_on "gettext"

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-e2initrd-helper"
    system "make"
    system "make", "install"
    system "make", "install-libs"
  end

  test do
    assert_equal 36, shell_output("#{bin}/uuidgen").strip.length
    system bin/"lsattr", "-al"
  end
end
