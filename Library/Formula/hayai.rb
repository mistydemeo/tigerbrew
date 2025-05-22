class Hayai < Formula
  desc "C++ benchmarking framework inspired by the googletest framework"
  homepage "http://nickbruun.dk/2012/02/07/easy-cpp-benchmarking"
  url "https://github.com/nickbruun/hayai/archive/v1.0.1.tar.gz"
  sha256 "40798cb3a7b5fcd4e0be65f9358dad4efeef7c4ebe8319327d99a2b8e5dcea4c"


  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <hayai/hayai.hpp>
      #include <iostream>
      int main() {
        hayai::Benchmarker::RunAllTests();
        return 0;
      }

      BENCHMARK(HomebrewTest, TestBenchmark, 1, 1)
      {
        std::cout << "Hayai works!" << std::endl;
      }
    EOS

    system ENV.cxx, "test.cpp", "-lhayai_main", "-o", "test"
    system "./test"
  end
end
