class Libbson < Formula
  desc "BSON utility library"
  homepage "https://github.com/mongodb/libbson"
  url "https://github.com/mongodb/libbson/releases/download/1.1.7/libbson-1.1.7.tar.gz"
  sha256 "94b11f9ce0bc118b9f4dc0470ce48aaf673278f4b22517c452e1f3f675d1abe3"


  def install
    system "./configure", "--enable-silent-rules", "--prefix=#{prefix}"
    system "make", "install"
  end
end
