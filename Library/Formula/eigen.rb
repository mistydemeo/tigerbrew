class Eigen < Formula
  desc "C++ template library for linear algebra"
  homepage "http://eigen.tuxfamily.org/"
  url "https://bitbucket.org/eigen/eigen/get/3.2.5.tar.bz2"
  sha256 "5f6e6cb88188e34185f43cb819d7dab9b48ef493774ff834e568f4805d3dc2f9"


  head "https://bitbucket.org/eigen/eigen", :using => :hg

  depends_on "cmake" => :build

  option :universal

  def install
    ENV.universal_binary if build.universal?
    mkdir "eigen-build" do
      args = std_cmake_args
      args << "-Dpkg_config_libdir=#{lib}" << ".."
      system "cmake", *args
      system "make", "install"
    end
    (share/"cmake/Modules").install "cmake/FindEigen3.cmake"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <iostream>
      #include <Eigen/Dense>
      using Eigen::MatrixXd;
      int main()
      {
        MatrixXd m(2,2);
        m(0,0) = 3;
        m(1,0) = 2.5;
        m(0,1) = -1;
        m(1,1) = m(1,0) + m(0,1);
        std::cout << m << std::endl;
      }
    EOS
    system ENV.cxx, "test.cpp", "-I#{include}/eigen3", "-o", "test"
    assert_equal `./test`.split, %w[3 -1 2.5 1.5]
  end
end
