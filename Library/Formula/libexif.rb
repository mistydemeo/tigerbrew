class Libexif < Formula
  desc "EXIF parsing library"
  homepage "http://libexif.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/libexif/libexif/0.6.21/libexif-0.6.21.tar.gz"
  sha256 "edb7eb13664cf950a6edd132b75e99afe61c5effe2f16494e6d27bc404b287bf"


  fails_with :llvm do
    build 2334
    cause "segfault with llvm"
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make", "install"
  end
end
