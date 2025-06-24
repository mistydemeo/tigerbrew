class Cabextract < Formula
  desc "Extract files from Microsoft cabinet files"
  homepage "http://www.cabextract.org.uk/"
  url "http://www.cabextract.org.uk/cabextract-1.6.tar.gz"
  sha256 "cee661b56555350d26943c5e127fc75dd290b7f75689d5ebc1f04957c4af55fb"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    # probably the smallest valid .cab file
    cab = <<-EOS.gsub(/\s+/, "")
      4d5343460000000046000000000000002c000000000000000301010001000000d20400003
      e00000001000000000000000000000000003246899d200061000000000000000000
    EOS
    (testpath/"test.cab").binwrite [cab].pack("H*")

    system "#{bin}/cabextract", "test.cab"
    assert File.exist? "a"
  end
end
