class TaLib < Formula
  desc "Tools for market analysis"
  homepage "http://ta-lib.org/index.html"
  url "https://downloads.sourceforge.net/project/ta-lib/ta-lib/0.4.0/ta-lib-0.4.0-src.tar.gz"
  sha256 "9ff41efcb1c011a4b4b6dfc91610b06e39b1d7973ed5d4dee55029a0ac4dc651"


  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
    bin.install "src/tools/ta_regtest/.libs/ta_regtest"
  end

  test do
    system "#{bin}/ta_regtest"
  end
end
