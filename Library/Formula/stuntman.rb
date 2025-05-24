class Stuntman < Formula
  desc "Implementation of the STUN protocol"
  homepage "http://www.stunprotocol.org/"
  url "http://www.stunprotocol.org/stunserver-1.2.7.tgz"
  sha256 "51415bf83339f059c6a65bbece9b758e3f198cb86063a0f1b4f12d825c87640e"
  head "https://github.com/jselbie/stunserver.git"
  revision 1


  depends_on "boost" => :build
  depends_on "openssl"

  def install
    system "make"
    bin.install "stunserver", "stunclient", "stuntestcode"
  end

  test do
    system "#{bin}/stuntestcode"
  end
end
