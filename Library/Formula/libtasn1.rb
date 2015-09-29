class Libtasn1 < Formula
  desc "ASN.1 structure parser library"
  homepage "https://www.gnu.org/software/libtasn1/"
  url "http://ftpmirror.gnu.org/libtasn1/libtasn1-4.7.tar.gz"
  mirror "https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.7.tar.gz"
  sha256 "a40780dc93fc6d819170240e8ece25352058a85fd1d2347ce0f143667d8f11c9"

  bottle do
    cellar :any
    sha256 "50cc8266e6239b597ee419b5437f3f8423c77999f4dcd6c12165495c324a65b0" => :tiger_altivec
    sha256 "c3db02178bb7db0112d8c4798332f2472057c9a56826dea60f8021b2cacece5f" => :leopard_g3
    sha256 "093f4d5a8774d7e0572233b814e32c2ebe2647ccbc9661adaf7cda18c0383b10" => :leopard_altivec
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking",
                          "--disable-silent-rules"
    system "make", "install"
  end

  test do
    (testpath/"pkix.asn").write <<-EOS.undent
      PKIX1 { }
      DEFINITIONS IMPLICIT TAGS ::=
      BEGIN
      Dss-Sig-Value ::= SEQUENCE {
           r       INTEGER,
           s       INTEGER
      }
      END
    EOS
    (testpath/"assign.asn1").write <<-EOS.undent
      dp PKIX1.Dss-Sig-Value
      r 42
      s 47
    EOS
    system "#{bin}/asn1Coding", "pkix.asn", "assign.asn1"
    assert_match /Decoding: SUCCESS/, shell_output("#{bin}/asn1Decoding pkix.asn assign.out PKIX1.Dss-Sig-Value 2>&1")
  end
end
