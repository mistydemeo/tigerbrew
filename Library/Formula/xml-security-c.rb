class XmlSecurityC < Formula
  desc "Implementation of primary security standards for XML"
  homepage "https://santuario.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=/santuario/c-library/xml-security-c-1.7.3.tar.gz"
  sha256 "e5226e7319d44f6fd9147a13fb853f5c711b9e75bf60ec273a0ef8a190592583"


  depends_on "pkg-config" => :build
  depends_on "xerces-c"
  depends_on "openssl"

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking",
                          "--with-openssl=#{Formula["openssl"].opt_prefix}"
    system "make", "install"
  end

  test do
    assert_match /All tests passed/, pipe_output("#{bin}/xtest 2>&1")
  end
end
