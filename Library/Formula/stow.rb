class Stow < Formula
  desc "Organize software neatly under a single directory tree (e.g. /usr/local)"
  homepage "https://www.gnu.org/software/stow/"
  url "http://ftpmirror.gnu.org/stow/stow-2.4.0.tar.gz"
  mirror "https://ftp.gnu.org/gnu/stow/stow-2.4.0.tar.gz"
  sha256 "6fed67cf64deab6d3d9151a43e2c06c95cdfca6a88fab7d416f46a648b1d761d"

  bottle do
  end

  # "GetOptionsFromArray" is not exported by the Getopt::Long module
  # when stow is built against Perl 5.8.6 from Tiger
  depends_on "perl"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test").mkpath
    system "#{bin}/stow", "-nvS", "test"
  end
end
