require 'formula'

class Gist < Formula
  homepage 'https://github.com/defunkt/gist'
  url 'https://github.com/defunkt/gist/archive/v4.2.1.tar.gz'
  sha1 'a081ce290e601263c2e42cc3c584c2cd23f06951'
  head 'https://github.com/defunkt/gist.git'

  # rake wasn't shipped with Ruby back in 1.8.2
  depends_on :macos => :leopard

  def install
    rake "install", "prefix=#{prefix}"
  end

  test do
    system "#{bin}/gist", '--version'
  end
end
