class CodaCli < Formula
  desc "Shell integration for Panic's Coda"
  homepage "https://web.archive.org/web/20230602191317/http://justinhileman.info/coda-cli/"
  url "https://github.com/bobthecow/coda-cli/archive/v1.0.5.tar.gz"
  sha256 "5ed407313a8d1fc6cc4d5b1acc14a80f7e6fad6146f2334de510e475955008b9"

  def install
    bin.install "coda"
  end

  test do
    system "#{bin}/coda", "-h"
  end
end
