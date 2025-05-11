class CurlCaBundle < Formula
  homepage "http://curl.haxx.se/docs/caextract.html"
  url "https://curl.se/ca/cacert-2025-02-25.pem",
    :using => :nounzip
  sha256 "50a6277ec69113f00c5fd45f09e8b97a4b3e32daa35d3a95ab30137a55386cef"
  version "2025-02-25"

  bottle do
    cellar :any
    sha256 "4a04c6b23bf5ba131f8cffcb607909cf48857b67e1011140c2150338a75dadc7" => :tiger_g3
    sha256 "4a04c6b23bf5ba131f8cffcb607909cf48857b67e1011140c2150338a75dadc7" => :tiger_altivec
  end

  def install
    share.install "cacert-#{version}.pem" => "ca-bundle.crt"
  end
end
