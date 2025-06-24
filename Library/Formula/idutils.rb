class Idutils < Formula
  desc "ID database and query tools"
  homepage "https://www.gnu.org/s/idutils/"
  url "http://ftpmirror.gnu.org/idutils/idutils-4.6.tar.xz"
  mirror "https://ftp.gnu.org/gnu/idutils/idutils-4.6.tar.xz"
  sha256 "8181f43a4fb62f6f0ccf3b84dbe9bec71ecabd6dfdcf49c6b5584521c888aac2"


  conflicts_with "coreutils", :because => "both install `gid` and `gid.1`"

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system bin/"mkid", "/usr/include"
    system bin/"lid", "FILE"
  end
end
