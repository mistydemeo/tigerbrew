require 'formula'

class Jsl < Formula
  homepage 'http://www.javascriptlint.com/'
  url 'http://www.javascriptlint.com/download/jsl-0.3.0-src.tar.gz'
  sha1 'f27ec18d1dd325f895bc1682d7be8872c213a986'

  def install
    cd 'src' do
      system 'make -f Makefile.ref'
      cd 'Darwin_DBG.OBJ' do
        bin.install 'jsl'
      end
    end
  end
end
