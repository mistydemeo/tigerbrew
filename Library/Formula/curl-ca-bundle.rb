class CurlCaBundle < Formula
  homepage "http://curl.haxx.se/docs/caextract.html"
  url "https://curl.se/ca/cacert-2023-01-10.pem",
    :using => :nounzip
  sha256 "fb1ecd641d0a02c01bc9036d513cb658bbda62a75e246bedbc01764560a639f0"
  version "2023-01-10"

  bottle do
    cellar :any
  end

  def install
    share.install "cacert-#{version}.pem" => "ca-bundle.crt"
  end
end
