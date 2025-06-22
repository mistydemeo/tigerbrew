class Minizinc < Formula
  desc "Medium-level constraint modeling language"
  homepage "https://www.minizinc.org/"
  url "https://github.com/MiniZinc/libminizinc/archive/2.0.6.tar.gz"
  sha256 "95b413c82f510e406f32bbb779fe1221a3b6bf2931854f61ca44bcefc0788f50"
  head "https://github.com/MiniZinc/libminizinc.git", :branch => "develop"

  bottle do
    cellar :any
    sha256 "57ecab3e20c9353ba8e0945c20885469b8e4890f4f931346f27398458c7241dd" => :yosemite
    sha256 "661e0eb3d7b3cb601ba4a1d08ebc277cfc42ab0d05370a6d9c9989e03abf7dd1" => :mavericks
    sha256 "6e450774291e5065beaef7337e66869cb698f1cb8bd07089d7d9ffe3188fca96" => :mountain_lion
  end

  depends_on :arch => :x86_64
  depends_on "cmake" => :build

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "cmake", "--build", ".", "--target", "install"
    end
  end

  test do
    system bin/"mzn2doc", share/"examples/functions/warehouses.mzn"
  end
end
