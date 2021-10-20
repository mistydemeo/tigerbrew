class Sfml < Formula
  # Don't update SFML until there's a corresponding CSFML release
  desc "Multi-media library with bindings for multiple languages"
  homepage "http://www.sfml-dev.org/"

  # SFML 2.2+ require Lion or newer
  if MacOS.version < :lion
    url "http://www.sfml-dev.org/download/sfml/2.1/SFML-2.1-sources.zip"
    sha256 "5f46d7748223be3f0c6a9fcf18c0016d227f7b1903cdbcd85f61ddbc82ef95bf"
    revision 1
  else
    url "http://www.sfml-dev.org/files/SFML-2.3-sources.zip"
    sha256 "a1dc8b00958000628c5394bc8438ba1aa5971fbeeef91a2cf3fa3fff443de7c1"
    revision 2
  end

  head "https://github.com/SFML/SFML.git"

  bottle do
    cellar :any
  end

  # SFML 2.x requires 10.5; it appears to be a substantial rewrite from 1.x,
  # so don't bother trying to support SFML 1.6 for 10.4
  depends_on :macos => :leopard
  depends_on "cmake" => :build
  depends_on "doxygen" => :optional
  depends_on "flac"
  depends_on "freetype"
  depends_on "glew"
  depends_on "jpeg"
  depends_on "libogg"
  depends_on "libsndfile"
  depends_on "libvorbis"
  depends_on "openal-soft" => :optional

  # https://github.com/Homebrew/homebrew/issues/40301
  depends_on :macos => :lion

  def install
    args = std_cmake_args
    args << "-DSFML_BUILD_DOC=TRUE" if build.with? "doxygen"

    # Always remove the "extlibs" to avoid install_name_tool failure
    # (https://github.com/Homebrew/homebrew/pull/35279) but leave the
    # headers that were moved there in https://github.com/SFML/SFML/pull/795
    rm_rf Dir["extlibs/*"] - ["extlibs/headers"]

    if MacOS.version < :lion
      # SFML tries to install contents from extlibs, even if they weren't
      # the actual copies linked against in the build
      inreplace "CMakeLists.txt", /install\(DIRECTORY extlibs\/libs-osx.+$/, ""

      # SFML 2.1 doesn't properly add a link flag for openal-soft
      ENV.append "LDFLAGS", "-lopenal"
    end

    system "cmake", ".", *args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include "Time.hpp"
      int main() {
        sf::Time t1 = sf::milliseconds(10);
        return 0;
      }
    EOS
    system ENV.cxx, "-I#{include}/SFML/System", "-L#{lib}", "-lsfml-system",
           testpath/"test.cpp", "-o", "test"
    system "./test"
  end
end
