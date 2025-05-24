class Sqlitebrowser < Formula
  desc "Visual tool to create, design, and edit SQLite databases"
  homepage "http://sqlitebrowser.org"
  url "https://github.com/sqlitebrowser/sqlitebrowser/archive/v3.7.0.tar.gz"
  sha256 "3093a1dcf5b3138c1adf29857d62249ab2b068e70b001869a31151763e28cc3a"

  head "https://github.com/sqlitebrowser/sqlitebrowser.git"


  depends_on "qt"
  depends_on "cmake" => :build
  depends_on "sqlite" => "with-functions"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
