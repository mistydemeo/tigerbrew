class CurlCaBundle < Formula
  homepage "http://curl.haxx.se/docs/caextract.html"
  url "https://curl.se/ca/cacert-2026-10-20.pem",
    :using => :nounzip
  sha256 "796f1389bfea13c0ed78f663b765baaff54a508e5483786bd6ece73c5e3e3cbe"
  version "2026-10-20"

  bottle do
    cellar :any
  end

  def install
    share.install "cacert-#{version}.pem" => "ca-bundle.crt"
  end
end
