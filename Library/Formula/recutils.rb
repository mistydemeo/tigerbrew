class Recutils < Formula
  desc "Tools to work with human-editable, plain text data files"
  homepage "https://www.gnu.org/software/recutils/"
  url "http://ftpmirror.gnu.org/recutils/recutils-1.7.tar.gz"
  mirror "https://ftp.gnu.org/gnu/recutils/recutils-1.7.tar.gz"
  sha256 "233dc6dedb1916b887de293454da7e36a74bed9ebea364f7e97e74920051bc31"


  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.csv").write <<-EOS.undent
      a,b,c
      1,2,3
    EOS
    system "#{bin}/csv2rec", "test.csv"
  end
end
