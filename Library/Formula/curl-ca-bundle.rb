class CurlCaBundle < Formula
  homepage "http://curl.haxx.se/docs/caextract.html"
  url "https://curl.se/ca/cacert-2024-07-02.pem",
    :using => :nounzip
  sha256 "1bf458412568e134a4514f5e170a328d11091e071c7110955c9884ed87972ac9"
  version "2024-07-02"

  bottle do
    cellar :any
  end

  def install
    share.install "cacert-#{version}.pem" => "ca-bundle.crt"
  end
end
