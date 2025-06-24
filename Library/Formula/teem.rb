class Teem < Formula
  desc "Libraries for scientific raster data"
  homepage "http://teem.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/teem/teem/1.11.0/teem-1.11.0-src.tar.gz"
  sha256 "a01386021dfa802b3e7b4defced2f3c8235860d500c1fa2f347483775d4c8def"
  head "https://teem.svn.sourceforge.net/svnroot/teem/teem/trunk"


  option "with-experimental-apps", "Build experimental apps"
  option "with-experimental-libs", "Build experimental libs"

  deprecated_option "experimental-apps" => "with-experimental-apps"
  deprecated_option "experimental-libs" => "with-experimental-libs"

  depends_on "cmake" => :build
  depends_on "libpng"

  def install
    args = std_cmake_args
    args << "-DBUILD_SHARED_LIBS:BOOL=ON"
    args << "-DBUILD_EXPERIMENTAL_APPS:BOOL=ON" if build.with? "experimental-apps"
    args << "-DBUILD_EXPERIMENTAL_LIBS:BOOL=ON" if build.with? "experimental-libs"

    # Installs CMake archive files directly into lib, which we discourage.
    # Workaround by adding version to libdir & then symlink into expected structure.
    args << "-DTeem_USE_LIB_INSTALL_SUBDIR:BOOL=ON"

    system "cmake", *args
    system "make", "install"

    lib.install_symlink Dir.glob(lib/"Teem-#{version}/*.dylib")
    (lib/"cmake/teem").install_symlink Dir.glob(lib/"Teem-#{version}/*.cmake")
  end

  test do
    system "#{bin}/nrrdSanity"
  end
end
