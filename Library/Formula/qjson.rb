class Qjson < Formula
  desc "Map JSON to QVariant objects"
  homepage "http://qjson.sourceforge.net"
  url "https://downloads.sourceforge.net/project/qjson/qjson/0.8.1/qjson-0.8.1.tar.bz2"
  mirror "https://mirrors.kernel.org/debian/pool/main/q/qjson/qjson_0.8.1.orig.tar.bz2"
  sha256 "cd4db5b956247c4991a9c3e95512da257cd2a6bd011357e363d02300afc814d9"
  head "https://github.com/flavio/qjson.git"


  depends_on "cmake" => :build
  depends_on "qt"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <qjson/parser.h>
      int main() {
        QJson::Parser parser;
        return 0;
      }
    EOS
    system ENV.cxx, "-I#{include}", "-L#{lib}", "-lqjson",
           testpath/"test.cpp", "-o", testpath/"test"
    system "./test"
  end
end
