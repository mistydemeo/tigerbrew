class Frei0r < Formula
  desc "Minimalistic plugin API for video effects"
  homepage "http://frei0r.dyne.org"
  url "https://files.dyne.org/frei0r/releases/frei0r-plugins-1.4.tar.gz"
  sha256 "8470fcabde9f341b729be3be16385ffc8383d6f3328213907a43851b6e83be57"


  depends_on "autoconf" => :build

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
