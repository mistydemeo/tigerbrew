class Editorconfig < Formula
  desc "Maintain consistent coding style between multiple editors"
  homepage "http://editorconfig.org"
  url "https://downloads.sourceforge.net/project/editorconfig/EditorConfig-C-Core/0.12.0/source/editorconfig-core-c-0.12.0.tar.gz"
  sha256 "98c581d1dce24158160c9235190ce93eeae121f978aa84a89c7de258b5122e01"


  option :universal

  head "https://github.com/editorconfig/editorconfig-core-c.git"

  depends_on "cmake" => :build
  depends_on "pcre"

  def install
    ENV.universal_binary if build.universal?

    system "cmake", ".", "-DCMAKE_INSTALL_PREFIX:PATH=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/editorconfig", "--version"
  end
end
