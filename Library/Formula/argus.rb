class Argus < Formula
  desc "Audit Record Generation and Utilization System server"
  homepage "http://qosient.com/argus/"
  url "http://qosient.com/argus/src/argus-3.0.8.1.tar.gz"
  sha256 "1fb921104c8bd843fb9f5a1c32b57b20bfe8cd8a103b3f1d9bb686b9e6c490a4"


  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end
