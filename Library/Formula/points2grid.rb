class Points2grid < Formula
  desc "Generate digital elevation models using local griding"
  homepage "https://github.com/CRREL/points2grid"
  url "https://github.com/CRREL/points2grid/archive/1.3.0.tar.gz"
  sha256 "87acdfd336fac20d2c2a22926b045c7f3f0fc925769a87393aff28b8c351c62b"
  revision 1


  depends_on :macos => :mavericks

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "gdal"

  def install
    args = std_cmake_args + ["-DWITH_GDAL=ON"]
    libexec.install "example.las"
    system "cmake", ".", *args
    system "make", "install"
  end

  test do
    system bin/"points2grid",
           "-i", libexec/"example.las",
           "-o", "example",
           "--max", "--output_format", "grid"
    assert_equal 13, File.read("example.max.grid").scan("423.820000").size
  end
end
