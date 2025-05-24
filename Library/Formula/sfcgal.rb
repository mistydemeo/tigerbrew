class Sfcgal < Formula
  desc "C++ wrapper library around CGAL"
  homepage "http://sfcgal.org/"
  url "https://github.com/Oslandia/SFCGAL/archive/v1.0.5.tar.gz"
  sha256 "a9cdaf7334bf28dc71c6338d090c1d1402041c5e320b6c2e3669f7758946a01c"
  revision 2


  depends_on "cmake" => :build
  depends_on "cgal"
  depends_on "gmp"
  depends_on "mpfr"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    assert_equal prefix.to_s, shell_output("#{bin}/sfcgal-config --prefix").strip
  end
end
