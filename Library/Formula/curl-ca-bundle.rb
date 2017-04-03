class CurlCaBundle < Formula
  homepage "http://curl.haxx.se/docs/caextract.html"
  url "https://curl.haxx.se/ca/cacert-2017-01-18.pem",
    :using => :nounzip
  sha256 "e62a07e61e5870effa81b430e1900778943c228bd7da1259dd6a955ee2262b47"
  version "2017-01-18"

  bottle do
    cellar :any
    sha256 "2ca60a8bbb648ded824dce45eb150fd0e9d32f8cbd983945db7bee4c6e58b1ea" => :tiger_g3
    sha256 "fba559a40c232629dade3aaa6c13206098d6428fc5716ed05002ed748c60f946" => :tiger_altivec
    sha256 "3ec0182385448739a37805ad3f1561ec44706506cb9fa15cd8573023c4e8fb0c" => :leopard_g3
    sha256 "b168b3d05821dd315a7a8665f63f6a327957f129dda209f20df9aaad45f0742d" => :leopard_altivec
  end

  def install
    share.install "cacert-#{version}.pem" => "ca-bundle.crt"
  end
end
