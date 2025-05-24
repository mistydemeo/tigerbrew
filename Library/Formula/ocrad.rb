class Ocrad < Formula
  desc "Optical character recognition (OCR) program"
  homepage "https://www.gnu.org/software/ocrad/"
  url "http://ftpmirror.gnu.org/ocrad/ocrad-0.25.tar.lz"
  mirror "https://ftp.gnu.org/gnu/ocrad/ocrad-0.25.tar.lz"
  sha256 "e710be9c030fbcbce2315077326c8268feb422c0bc39fa744644cbbd1f5d4dd4"


  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install", "CXXFLAGS=#{ENV.cxxflags}"
  end

  test do
    (testpath/"test.pbm").write <<-EOS.undent
      P1
      # This is an example bitmap of the letter "J"
      6 10
      0 0 0 0 1 0
      0 0 0 0 1 0
      0 0 0 0 1 0
      0 0 0 0 1 0
      0 0 0 0 1 0
      0 0 0 0 1 0
      1 0 0 0 1 0
      0 1 1 1 0 0
      0 0 0 0 0 0
      0 0 0 0 0 0
    EOS
    assert_equal "J", `#{bin}/ocrad #{testpath}/test.pbm`.strip
  end
end
