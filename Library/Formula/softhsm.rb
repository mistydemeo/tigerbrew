class Softhsm < Formula
  desc "Cryptographic store accessible through a PKCS#11 interface"
  homepage "https://www.opendnssec.org/softhsm/"
  url "https://dist.opendnssec.org/source/softhsm-2.0.0.tar.gz"
  sha256 "eae8065f6c472af24f4c056d6728edda0fd34306f41a818697f765a6a662338d"


  depends_on "botan"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"softhsm2.conf").write("directories.tokendir = #{testpath}")
    ENV["SOFTHSM2_CONF"] = "#{testpath}/softhsm2.conf"
    system *%W[#{bin}/softhsm2-util --init-token --slot 0 --label testing --so-pin 1234 --pin 1234]
    system *%W[#{bin}/softhsm2-util --show-slots]
  end
end
