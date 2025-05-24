class Flickcurl < Formula
  desc "Library for the Flickr API"
  homepage "http://librdf.org/flickcurl/"
  url "http://download.dajobe.org/flickcurl/flickcurl-1.26.tar.gz"
  sha256 "ff42a36c7c1c7d368246f6bc9b7d792ed298348e5f0f5d432e49f6803562f5a3"


  depends_on "pkg-config" => :build

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/flickcurl -h 2>&1", 1)
    assert output.include? "flickcurl: Configuration file"
  end
end
