class Cppformat < Formula
  desc "Open-source formatting library for C++"
  homepage "https://web.archive.org/web/20160325180910/http://cppformat.github.io/latest/index.html"
  url "https://github.com/ibayer/cppformat/archive/refs/tags/2.0.0.tar.gz"
  sha256 "2f333779a0709cc28490a4ac0690ba9f64db52c2883a971997aab1c2fbd6f6af"

  bottle do
    cellar :any
  end

  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <iostream>
      #include <string>
      #include <format.h>
      int main()
      {
        std::string str = fmt::format("The answer is {}", 42);
        std::cout << str;
        return 0;
      }
    EOS

    system ENV.cxx, "test.cpp", "-o", "test",
                  "-I#{include}/cppformat",
                  "-L#{lib}",
                  "-lcppformat"
    assert_equal "The answer is 42", shell_output("./test")
  end
end
