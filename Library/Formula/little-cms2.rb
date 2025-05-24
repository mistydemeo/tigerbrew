class LittleCms2 < Formula
  desc "Color management engine supporting ICC profiles"
  homepage "http://www.littlecms.com/"
  url "https://downloads.sourceforge.net/project/lcms/lcms/2.7/lcms2-2.7.tar.gz"
  sha256 "4524234ae7de185e6b6da5d31d6875085b2198bc63b1211f7dde6e2d197d6a53"
  revision 1


  depends_on "jpeg" => :recommended
  depends_on "libtiff" => :recommended

  option :universal

  def install
    ENV.universal_binary if build.universal?

    args = %W[--disable-dependency-tracking --prefix=#{prefix}]
    args << "--without-tiff" if build.without? "libtiff"
    args << "--without-jpeg" if build.without? "jpeg"

    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{bin}/jpgicc", test_fixtures("test.jpg"), "out.jpg"
    assert File.exist?("out.jpg")
  end
end
