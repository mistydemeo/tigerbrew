class CurlCaBundle < Formula
  homepage "http://curl.haxx.se/docs/caextract.html"
  url "https://curl.se/ca/cacert-2024-12-31.pem",
    :using => :nounzip
  sha256 "a3f328c21e39ddd1f2be1cea43ac0dec819eaa20a90425d7da901a11531b3aa5"
  version "2024-12-31"

  bottle do
    cellar :any
    sha256 "0bd81857043bcd62c6ba1697e3e112f40c3e9b1031ab059a27f39995f419c16e" => :tiger
  end

  def install
    share.install "cacert-#{version}.pem" => "ca-bundle.crt"
  end
end
