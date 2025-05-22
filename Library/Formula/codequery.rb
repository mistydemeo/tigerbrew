class Codequery < Formula
  desc "Index, query, or search C, C++, Java, Python, Ruby, or Go code"
  homepage "https://github.com/ruben2020/codequery"
  url "https://github.com/ruben2020/codequery/archive/v0.16.0.tar.gz"
  sha256 "4896435a8aa35dbdca43cba769aece9731f647ac9422a92c3209c2955d2e7101"


  depends_on "cmake" => :build
  depends_on "qt"
  depends_on "qscintilla2"

  def install
    share.install "test"
    mkdir "build" do
      system "cmake", "..", "-G", "Unix Makefiles", *std_cmake_args
      system "make"
      system "make", "install"
    end
  end

  test do
    cd share+"test" do
      system "#{bin}/cqmakedb", "-s", "./codequery.db", "-c", "./cscope.out", "-t", "./tags", "-p"
      assert_match "info_platform", `#{bin}/cqsearch -s ./codequery.db -t 'info_platform'`
    end
  end
end
