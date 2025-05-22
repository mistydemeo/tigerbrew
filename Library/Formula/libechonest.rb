class Libechonest < Formula
  desc "Qt library for communicating with The Echo Nest"
  homepage "https://projects.kde.org/projects/playground/libs/libechonest"
  url "http://files.lfranchi.com/libechonest-2.3.1.tar.bz2"
  sha256 "56756545fd1cb3d9067479f52215b6157c1ced2bc82b895e72fdcd9bebb47889"


  depends_on "cmake" => :build
  depends_on "qt"
  depends_on "qjson"

  conflicts_with "doxygen", :because => "cmake fails to configure build."

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <echonest/Genre.h>
      #include <echonest/Artist.h>
      int main() {
        Echonest::Genre test;
        test.setName(QLatin1String("ambient trance"));
        return 0;
      }
    EOS
    qt = Formula["qt"]
    system ENV.cxx, "test.cpp", "-L#{lib}", "-lechonest", "-F#{qt.opt_lib}",
      "-framework", "QtCore", "-I#{qt.opt_include}/QtCore",
      "-I#{qt.opt_include}/QtNetwork", "-o", "test"
    system "./test"
  end
end
