class Epeg < Formula
  desc "JPEG/JPG thumbnail scaling"
  homepage "https://github.com/mattes/epeg"
  url "https://github.com/mattes/epeg/archive/v0.9.1.042.tar.gz"
  sha256 "644362f87605e92f1e1cc0c421867252e4402939aeb4b36ad7cb385cc57a137c"
  revision 1

  head "https://github.com/mattes/epeg.git"


  depends_on "automake" => :build
  depends_on "jpeg"
  depends_on "libexif"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "epeg", "--width=1",
                   "--height=1",
                   test_fixtures("test.jpg")
    "out.jpg"
  end
end
