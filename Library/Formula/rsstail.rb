class Rsstail < Formula
  desc "Monitors an RSS feed and emits new entries when detected"
  homepage "http://www.vanheusden.com/rsstail/"
  url "http://www.vanheusden.com/rsstail/rsstail-2.0.tgz"
  sha256 "647537197fb9fb72b08e04710d462ad9314a6335c0a66fb779fe9d822c19ee2a"

  head "https://github.com/flok99/rsstail.git"


  depends_on "libmrss"

  def install
    system "make"
    man1.install "rsstail.1"
    bin.install "rsstail"
  end

  test do
    assert_match(/^Title: NA-\d\d\d-\d\d\d\d-\d\d-\d\d$/,
                 shell_output("#{bin}/rsstail -1u http://feed.nashownotes.com/rss.xml"))
  end
end
