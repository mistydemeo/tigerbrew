class Oniguruma < Formula
  desc "Regular expressions library"
  homepage "https://github.com/kkos/oniguruma/"
  url "https://github.com/kkos/oniguruma/releases/download/v6.9.8/onig-6.9.8.tar.gz"
  sha256 "28cd62c1464623c7910565fb1ccaaa0104b2fe8b12bcd646e81f73b47535213e"

  bottle do
    cellar :any
    sha256 "38b40d3467c15f25c0ee58508cb5408db9474ca7b1c9b6754d8b901d7417f32b" => :tiger_altivec
  end

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_match /#{prefix}/, shell_output("#{bin}/onig-config --prefix")
  end
end
