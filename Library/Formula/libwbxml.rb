class Libwbxml < Formula
  desc "Library and tools to parse and encode WBXML documents"
  homepage "https://libwbxml.opensync.org/"
  url "https://downloads.sourceforge.net/project/libwbxml/libwbxml/0.11.2/libwbxml-0.11.2.tar.bz2"
  sha256 "5f642027ece0225d80ef21979a57cf59b1027d46cb8dbd5ff4b87662eec2557d"


  option "with-docs", "Build the documentation with Doxygen and Graphviz"
  deprecated_option "docs" => "with-docs"

  depends_on "cmake" => :build
  depends_on "wget" => :optional

  if build.with? "docs"
    depends_on "doxygen" => :build
    depends_on "graphviz" => :build
  end

  def install
    mkdir "build" do
      args = std_cmake_args + %w[..]
      args << "-DBUILD_DOCUMENTATION=ON" if build.with? "docs"
      system "cmake", *args
      system "make", "install"
    end
  end
end
