class Exiftags < Formula
  desc "Utility to read EXIF tags from a digital camera JPEG file"
  homepage "http://johnst.org/sw/exiftags"
  url "http://johnst.org/sw/exiftags/exiftags-1.01.tar.gz"
  sha256 "d95744de5f609f1562045f1c2aae610e8f694a4c9042897a51a22f0f0d7591a4"


  def install
    bin.mkpath
    man1.mkpath
    system "make", "prefix=#{prefix}", "mandir=#{man}", "install"
  end

  test do
    system "#{bin}/exiftags", test_fixtures("test.jpg")
  end
end
