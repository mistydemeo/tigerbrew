class CurlCaBundle < Formula
  homepage "http://curl.haxx.se/docs/caextract.html"
  url "https://curl.se/ca/cacert-2021-09-30.pem",
    :using => :nounzip
  mirror "https://ia902307.us.archive.org/31/items/tigerbrew/cacert-2021-09-30.pem"
  sha256 "f524fc21859b776e18df01a87880efa198112214e13494275dbcbd9bcb71d976"
  version "2021-09-30"

  bottle do
    cellar :any
  end

  def install
    share.install "cacert-#{version}.pem" => "ca-bundle.crt"
  end
end
