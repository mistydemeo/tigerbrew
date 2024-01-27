class Exiftool < Formula
  desc "Perl lib for reading and writing EXIF metadata"
  homepage "https://exiftool.org/index.html"
  url "https://exiftool.org/Image-ExifTool-12.74.tar.gz"
  sha256 "aedb28b1427c53205ab261fa31ff3feda73e7f17a0c181453651680e5666c48a"

  bottle do
    cellar :any_skip_relocation
  end

  def install
    # replace the hard-coded path to the lib directory
    inreplace "exiftool", "$exeDir/lib", "#{libexec}/lib"

    system "perl", "Makefile.PL"

    libexec.install "lib"
    bin.install "exiftool"
  end

  test do
    system "#{bin}/exiftool"
  end
end
