class Libcdio < Formula
  desc "Compact Disc Input and Control Library"
  homepage "https://www.gnu.org/software/libcdio/"
  url "http://ftpmirror.gnu.org/libcdio/libcdio-0.93.tar.gz"
  mirror "https://ftp.gnu.org/gnu/libcdio/libcdio-0.93.tar.gz"
  sha256 "4972cd22fd8d0e8bff922d35c7a645be0db0ab0e7b3dfaecc9cd8272429d6975"


  depends_on "pkg-config" => :build

  def install
    system "./configure", "--disable-dependency-tracking", "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_match /#{version}/, shell_output("#{bin}/cd-info -v", 1)
  end
end
