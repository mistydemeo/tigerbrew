class CurlCaBundle < Formula
  homepage "http://curl.haxx.se/docs/caextract.html"
  url "https://raw.githubusercontent.com/bagder/ca-bundle/bff056d04b9e2c92ea8c83b2e39be9c8d0501039/ca-bundle.crt",
    :using => :nounzip
  sha256 "0f119da204025da7808273fab42ed8e030cafb5c7ea4e1deda4e75f066f528fb"
  version "2015-04-27"

  bottle do
    cellar :any
    sha1 "1a2ddcf4287a970f3951eac1654d47c05e12c330" => :leopard_g3
    sha1 "34afbe9099fecb7e01bb345490b42795386555db" => :leopard_altivec
  end

  def install
    share.install "ca-bundle.crt"
  end
end
