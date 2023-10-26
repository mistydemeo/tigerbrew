class Ldns < Formula
  desc "DNS library written in C"
  homepage "https://nlnetlabs.nl/projects/ldns/"
  url "https://nlnetlabs.nl/downloads/ldns/ldns-1.8.3.tar.gz"
  sha256 "c3f72dd1036b2907e3a56e6acf9dfb2e551256b3c1bbd9787942deeeb70e7860"
  revision 1

  bottle do
  end

  depends_on :python => :optional
  depends_on "openssl3"
  depends_on "swig" => :build if build.with? "python"

  def install
    args = %W[
      --prefix=#{prefix}
      --with-drill
      --with-examples
      --with-ssl=#{Formula["openssl3"].opt_prefix}
    ]

    args << "--with-pyldns" if build.with? "python"

    system "./configure", *args
    system "make"
    system "make", "install"
    system "make", "install-pyldns" if build.with? "python"
    (lib/"pkgconfig").install "packaging/libldns.pc"
  end

  test do
    (testpath/"powerdns.com.dnskey").write("powerdns.com.   10773 IN  DNSKEY  256 3 8 AwEAAbQOlJUPNWM8DQown5y/wFgDVt7jskfEQcd4pbLV/1osuBfBNDZX v9ru7wDC/PbpvysEZgFXTPJ9QrdwSsd8KAZVO5mjeDNL0RnlhjHWuXKC qnLI+iLb3OMLQTizjdscdHPoW98wk5931pJkyf2qMDRjRB4c5d81sfoZ Od6D7Rrx\npowerdns.com.   10773 IN  DNSKEY  257 3 8 AwEAAb/+pXOZWYQ8mv9WM5dFva8WU9jcIUdDuEjldbyfnkQ/xlrJC5zA EfhYhrea3SmIPmMTDimLqbh3/4SMTNPTUF+9+U1vpNfIRTFadqsmuU9F ddz3JqCcYwEpWbReg6DJOeyu+9oBoIQkPxFyLtIXEPGlQzrynKubn04C x83I6NfzDTraJT3jLHKeW5PVc1ifqKzHz5TXdHHTA7NkJAa0sPcZCoNE 1LpnJI/wcUpRUiuQhoLFeT1E432GuPuZ7y+agElGj0NnBxEgnHrhrnZW UbULpRa/il+Cr5Taj988HqX9Xdm6FjcP4Lbuds/44U7U8du224Q8jTrZ 57Yvj4VDQKc=")
    system "#{bin}/ldns-key2ds", "powerdns.com.dnskey"
    assert_match /d4c3d5552b8679faeebc317e5f048b614b2e5f607dc57f1553182d49ab2179f7/, File.read("Kpowerdns.com.+008+44030.ds")
  end
end
