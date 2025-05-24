class Ldc < Formula
  desc "Portable D programming language compiler"
  homepage "http://wiki.dlang.org/LDC"
  url "https://github.com/ldc-developers/ldc/releases/download/v0.15.2-beta2/ldc-0.15.2-beta2-src.tar.gz"
  version "0.15.2-beta2"
  sha256 "b421acbca0cdeef42c5af2bd53060253822dea6d78d216f973ee5e2b362723e2"

  head "https://github.com/ldc-developers/ldc.git", :shallow => false


  devel do
    url "https://github.com/ldc-developers/ldc/releases/download/v0.16.0-beta1/ldc-0.16.0-beta1-src.tar.gz"
    version "0.16.0-beta1"
    sha256 "35fac8a724cee8dc280c926d659c39b4209a0e9739be55943e4fd687b6d18049"
  end

  needs :cxx11

  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on "libconfig"

  def install
    ENV.cxx11
    mkdir "build"
    cd "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.d").write <<-EOS.undent
      import std.stdio;

      void main() {
        writeln("Hello, world!");
      }
    EOS

    system "#{bin}/ldc2", "test.d"
    system "./test"
    system "#{bin}/ldmd2", "test.d"
    system "./test"
  end
end
