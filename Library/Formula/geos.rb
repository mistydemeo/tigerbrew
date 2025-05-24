class Geos < Formula
  desc "GEOS Geometry Engine"
  homepage "https://trac.osgeo.org/geos"
  url "http://download.osgeo.org/geos/geos-3.4.2.tar.bz2"
  sha256 "15e8bfdf7e29087a957b56ac543ea9a80321481cef4d4f63a7b268953ad26c53"


  option :universal
  option :cxx11
  option "with-php", "Build the PHP extension"
  option "with-python", "Build the Python extension"
  option "with-ruby", "Build the ruby extension"

  depends_on "swig" => :build if build.with?("python") || build.with?("ruby")

  fails_with :llvm

  def install
    ENV.universal_binary if build.universal?
    ENV.cxx11 if build.cxx11?

    args = [
      "--disable-dependency-tracking",
      "--prefix=#{prefix}"
    ]

    args << "--enable-php" if build.with?("php")
    args << "--enable-python" if build.with?("python")
    args << "--enable-ruby" if build.with?("ruby")

    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{bin}/geos-config", "--libs"
  end
end
