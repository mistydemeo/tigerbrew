class Ccextractor < Formula
  desc "Free, GPL licensed closed caption tool"
  homepage "http://ccextractor.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/ccextractor/ccextractor/0.75/ccextractor.src.0.75.zip"
  sha256 "fb6ed33d516b9198e1b625fec4fce99f079e28f1c556eff4552f53c92ecc9cca"
  head "https://github.com/ccextractor/ccextractor.git"
  revision 1

  depends_on "cmake" => :build
  depends_on "libpng"


  def install
    system "cmake", "src", *std_cmake_args
    system "make"
    system "make", "install"
    (share/"examples").install "docs/ccextractor.cnf.sample"
  end

  test do
    touch testpath/"test"
    system "ccextractor", "test"
    assert File.exist? "test.srt"
  end
end
