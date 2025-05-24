class Libcsv < Formula
  desc "CSV library in ANSI C89"
  homepage "http://sourceforge.net/projects/libcsv/"
  url "https://downloads.sourceforge.net/project/libcsv/libcsv/libcsv-3.0.3/libcsv-3.0.3.tar.gz"
  sha256 "d9c0431cb803ceb9896ce74f683e6e5a0954e96ae1d9e4028d6e0f967bebd7e4"


  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end
