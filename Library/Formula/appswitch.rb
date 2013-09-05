require 'formula'

class Appswitch < Formula
  homepage 'http://web.sabi.net/nriley/software/'
  url 'http://web.sabi.net/nriley/software/appswitch-1.1.tar.gz'
  sha1 'e62b142927386c905a70e00d3647cfcd1d06955b'

  # This isn't the latest version of appswitch, but it is the latest
  # version that will work on PPC with Tiger/Leopard.

  def install
    # Because the tarball always comes with a precompiled binary and because
    # compiling this now would require using xcodebuild from a full XCode
    # install, let's just use the binary so that we can support CLT only.
    man1.install gzip('appswitch.1')
    bin.install 'appswitch'
  end
end
