class CurlCaBundle < Formula
  homepage "http://curl.haxx.se/docs/caextract.html"
  url "https://curl.se/ca/cacert-2024-12-31.pem",
    :using => :nounzip
  sha256 "a3f328c21e39ddd1f2be1cea43ac0dec819eaa20a90425d7da901a11531b3aa5"
  version "2024-12-31"

  bottle do
    cellar :any
  end

  def install
    share.install "cacert-#{version}.pem" => "ca-bundle.crt"
  end
end
