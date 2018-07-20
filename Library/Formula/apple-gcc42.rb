require 'formula'

class AppleGcc42 < Formula
  homepage 'http://r.research.att.com/tools/'
  url 'https://ia902307.us.archive.org/31/items/tigerbrew/gcc-42-5553-darwin8-all.tar.gz'
  mirror 'http://r.research.att.com/gcc-42-5553-darwin8-all.tar.gz'
  version '4.2.1-5553'
  sha1 '0e529a2e4723e016e3d086d6ca3215d700931503'

  def install
    cd 'usr' do
      prefix.install Dir['*']
    end
  end

  def caveats
    <<-EOS.undent
      This formula contains compilers built from Apple's GCC sources, build
      5553, available from:

        http://opensource.apple.com/tarballs/gcc

      All compilers have a `-4.2` suffix. A GFortran compiler is also included.
    EOS
  end
end
