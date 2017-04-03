class CurlCaBundle < Formula
  homepage "http://curl.haxx.se/docs/caextract.html"
  url "https://curl.haxx.se/ca/cacert-2017-01-18.pem",
    :using => :nounzip
  sha256 "e62a07e61e5870effa81b430e1900778943c228bd7da1259dd6a955ee2262b47"
  version "2017-01-18"

  bottle do
    cellar :any
    sha256 "0507b35196c0cd269f7e209353f88154b0c4232b1f28c1ecdaeb2c89e368d927" => :tiger
    sha256 "0507b35196c0cd269f7e209353f88154b0c4232b1f28c1ecdaeb2c89e368d927" => :tiger_g3
    sha256 "0507b35196c0cd269f7e209353f88154b0c4232b1f28c1ecdaeb2c89e368d927" => :tiger_altivec
    sha256 "b7a31dae293c4c39092690a1a4b43a6bd1ff6419daae4899245f469717aa8712" => :leopard
    sha256 "b7a31dae293c4c39092690a1a4b43a6bd1ff6419daae4899245f469717aa8712" => :leopard_g3
    sha256 "b7a31dae293c4c39092690a1a4b43a6bd1ff6419daae4899245f469717aa8712" => :leopard_altivec
  end

  def install
    share.install "cacert-#{version}.pem" => "ca-bundle.crt"
  end
end
