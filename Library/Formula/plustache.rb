require 'formula'

class Plustache < Formula
  homepage 'https://github.com/mrtazz/plustache'
  url 'https://github.com/mrtazz/plustache/archive/v0.2.0.tar.gz'
  sha1 '10096ccefed6669b5c87945d7fa6c0a011549eca'

  # rake wasn't shipped with Ruby back in 1.8.2
  depends_on :macos => :leopard
  depends_on 'boost'

  def install
    rake "install", "prefix=#{prefix}"
  end
end
