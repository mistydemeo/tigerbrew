class CurlCaBundle < Formula
  homepage "http://curl.haxx.se/docs/caextract.html"
  url "https://curl.se/ca/cacert-2025-12-02.pem",
    :using => :nounzip
  sha256 "f1407d974c5ed87d544bd931a278232e13925177e239fca370619aba63c757b4"
  version "2025-12-02"

  bottle do
    cellar :any
  end

  def install
    share.install "cacert-#{version}.pem" => "ca-bundle.crt"
  end
end
