class CurlCaBundle < Formula
  homepage "http://curl.haxx.se/docs/caextract.html"
  url "https://curl.se/ca/cacert-2025-07-15.pem",
    :using => :nounzip
  sha256 "7430e90ee0cdca2d0f02b1ece46fbf255d5d0408111f009638e3b892d6ca089c"
  version "2025-07-15"

  bottle do
    cellar :any
  end

  def install
    share.install "cacert-#{version}.pem" => "ca-bundle.crt"
  end
end
