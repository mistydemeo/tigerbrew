class Gist < Formula
  desc "Command-line utility for uploading Gists"
  homepage "https://github.com/defunkt/gist"
  url "https://github.com/defunkt/gist/archive/v4.4.2.tar.gz"
  sha256 "4f570c6c32f04f529d0195c7cad93a48c9a53b2b3a9e69f68b732cdf31d3c362"
  head "https://github.com/defunkt/gist.git"


  # rake wasn't shipped with Ruby back in 1.8.2
  depends_on :macos => :leopard

  def install
    rake "install", "prefix=#{prefix}"
  end

  test do
    system "#{bin}/gist", "--version"
  end
end
