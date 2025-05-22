class Minizinc < Formula
  desc "Medium-level constraint modeling language"
  homepage "http://www.minizinc.org"
  url "https://github.com/MiniZinc/libminizinc/archive/2.0.6.tar.gz"
  sha256 "95b413c82f510e406f32bbb779fe1221a3b6bf2931854f61ca44bcefc0788f50"
  head "https://github.com/MiniZinc/libminizinc.git", :branch => "develop"


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
