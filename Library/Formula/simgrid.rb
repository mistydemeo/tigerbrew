class Simgrid < Formula
  desc "Studies behavior of large-scale distributed systems"
  homepage "http://simgrid.gforge.inria.fr"
  url "http://gforge.inria.fr/frs/download.php/file/33686/SimGrid-3.11.1.tar.gz"
  sha256 "7796ef6d4288462fdabdf5696c453ea6aabc433a813a384db2950ae26eff7956"


  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "pcre"
  depends_on "graphviz"

  def install
    system "cmake", ".",
                    "-Denable_debug=on",
                    "-Denable_compile_optimizations=off",
                    *std_cmake_args
    system "make", "install"
  end
end
