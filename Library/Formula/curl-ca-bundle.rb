class CurlCaBundle < Formula
  homepage "http://curl.haxx.se/docs/caextract.html"
  url "https://curl.se/ca/cacert-2024-09-24.pem",
    :using => :nounzip
  sha256 "189d3cf6d103185fba06d76c1af915263c6d42225481a1759e853b33ac857540"
  version "2024-09-24"

  bottle do
    cellar :any
  end

  def install
    share.install "cacert-#{version}.pem" => "ca-bundle.crt"
  end
end
