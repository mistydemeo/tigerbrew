class BoostBcp < Formula
  desc "Utility for extracting subsets of the Boost library"
  homepage "http://www.boost.org/doc/tools/bcp/"
  url "https://downloads.sourceforge.net/project/boost/boost/1.58.0/boost_1_58_0.tar.bz2"
  sha256 "fdfc204fc33ec79c99b9a74944c3e54bd78be4f7f15e260c0e2700a36dc7d3e5"

  head "https://github.com/boostorg/boost.git"


  depends_on "boost-build" => :build

  def install
    cd "tools/bcp" do
      system "b2"
      prefix.install "../../dist/bin"
    end
  end

  test do
    system bin/"bcp", "--help"
  end
end
