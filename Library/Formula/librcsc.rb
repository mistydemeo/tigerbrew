class Librcsc < Formula
  desc "RoboCup Soccer Simulator library"
  homepage "https://web.archive.org/web/20160719125342/https://osdn.jp/projects/rctools/"
  url "http://dl.osdn.jp/rctools/51941/librcsc-4.1.0.tar.gz"
  sha256 "1e8f66927b03fb921c5a2a8c763fb7297a4349c81d1411c450b180178b46f481"

  bottle do
    cellar :any
    revision 1
    sha1 "7db2070cbe574575393712c697fc743a138129e7" => :yosemite
    sha1 "27075e4e199258cc61e287464d7bf255fc4702ac" => :mavericks
    sha1 "9607e6d54b8a36202294ed27a71b2142cee8ee95" => :mountain_lion
  end

  depends_on "boost"

  def install
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <rcsc/rcg.h>
      int main() {
        rcsc::rcg::PlayerT p;
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-o", "test", "-lrcsc_rcg"
    system "./test"
  end
end
