class Sqlitebrowser < Formula
  desc "Visual tool to create, design, and edit SQLite databases"
  homepage "http://sqlitebrowser.org"
  url "https://github.com/sqlitebrowser/sqlitebrowser/archive/refs/tags/v3.9.1.tar.gz"
  sha256 "d0d2e06a69927ba1d0b955f3261ce70c61befc5bd5ddaa06752dae8bb4219ed8"

  head "https://github.com/sqlitebrowser/sqlitebrowser.git"

  bottle do
    cellar :any
  end

  # GCC 4.0 C++ support is lacking.
  fails_with :gcc_4_0
  # GCC 4.2 on Tiger struggles with 10.4u SDK "error: stdarg.h: No such file or directory"
  fails_with :gcc if MacOS.version == :tiger

  depends_on "qt"
  depends_on "cmake" => :build
  depends_on "sqlite" => "with-functions"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
