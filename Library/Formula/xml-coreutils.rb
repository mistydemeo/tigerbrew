class XmlCoreutils < Formula
  desc "Powerful interactive system for text processing"
  homepage "http://www.lbreyer.com/xml-coreutils.html"
  url "http://www.lbreyer.com/gpl/xml-coreutils-0.8.1.tar.gz"
  sha256 "7fb26d57bb17fa770452ccd33caf288deee1d757a0e0a484b90c109610d1b7df"


  depends_on "s-lang"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.xml").write <<-EOS.undent
      <hello>world!</hello>
    EOS
    assert_match /0\s+1\s+1/, shell_output("#{bin}/xml-wc test.xml")
  end
end
