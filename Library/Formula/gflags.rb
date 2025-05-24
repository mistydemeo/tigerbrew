class Gflags < Formula
  desc "Library for processing command-line flags"
  homepage "https://gflags.github.io/gflags/"
  url "https://github.com/gflags/gflags/archive/v2.1.2.tar.gz"
  sha256 "d8331bd0f7367c8afd5fcb5f5e85e96868a00fd24b7276fa5fcee1e5575c2662"


  option "with-debug", "Build debug version"
  option "with-static", "Build gflags as a static (instead of shared) library."

  depends_on "cmake" => :build

  def install
    ENV.append_to_cflags "-DNDEBUG" if build.without? "debug"
    args = std_cmake_args
    if build.with? "static"
      args << "-DBUILD_SHARED_LIBS=OFF"
    else
      args << "-DBUILD_SHARED_LIBS=ON"
    end
    mkdir "buildroot" do
      system "cmake", "..", *args
      system "make", "install"
    end
  end
end
