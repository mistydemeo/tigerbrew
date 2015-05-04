class CurlCaBundle < Formula
  homepage "http://curl.haxx.se/docs/caextract.html"
  url "https://raw.githubusercontent.com/bagder/ca-bundle/b072e4efd42b8602855bba127586c42fcf4f73d5/ca-bundle.crt",
    :using => :nounzip
  sha256 "8c7a422750d1ff035b940bb74c13fdea2d1dc55cda1eafb68201088ed4b47d35"
  version "2014-09-04"

  bottle do
    cellar :any
    sha1 "1a2ddcf4287a970f3951eac1654d47c05e12c330" => :leopard_g3
    sha1 "34afbe9099fecb7e01bb345490b42795386555db" => :leopard_altivec
  end

  def install
    share.install "ca-bundle.crt"
  end

  def caveats; <<-EOS.undent
    To use these certificates with OpenSSL:

      export SSL_CERT_FILE=#{opt_share}/ca-bundle.crt
    EOS
  end
end
