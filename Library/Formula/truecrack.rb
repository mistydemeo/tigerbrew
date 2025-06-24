class Truecrack < Formula
  desc "Brute-force password cracker for TrueCrypt"
  homepage "https://code.google.com/p/truecrack/"
  url "https://truecrack.googlecode.com/files/truecrack_v35.tar.gz"
  sha256 "25bf270fa3bc3591c3d795e5a4b0842f6581f76c0b5d17c0aef260246fe726b3"
  version "3.5"


  # Fix missing return value compilation issue
  # https://code.google.com/p/truecrack/issues/detail?id=41
  patch do
    url "https://gist.githubusercontent.com/anonymous/b912a1ede06eb1e8eb38/raw/1394a8a6bedb7caae8ee034f512f76a99fe55976/truecrack-return-value-fix.patch"
    sha256 "8aa608054f9b822a1fb7294a5087410f347ba632bbd4b46002aada76c289ed77"
  end

  def install
    system "./configure", "--enable-cpu",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/truecrack"
  end
end
