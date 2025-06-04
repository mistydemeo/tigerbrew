class CurlCaBundle < Formula
  homepage "http://curl.haxx.se/docs/caextract.html"
  url "https://curl.se/ca/cacert-2025-05-20.pem",
    :using => :nounzip
  sha256 "ab3ee3651977a4178a702b0b828a4ee7b2bbb9127235b0ab740e2e15974bf5db"
  version "2025-05-20"

  bottle do
    cellar :any
  end

  def install
    share.install "cacert-#{version}.pem" => "ca-bundle.crt"
  end
end
