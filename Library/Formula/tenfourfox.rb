require 'formula'

class Tenfourfox < Formula
  homepage 'http://www.floodgap.com/software/tenfourfox/'
  urlbase = 'https://downloads.sourceforge.net/tenfourfox/'
  version '24.5.0'

  depends_on :arch => :ppc

  urls = {
    :g3 => ['G3', '52164ae84ae5dde0f4b6876b75965d04b6667010'],
    :g4 => ['7400', 'd151431f3fb9836669efc89be2dacdd030e98157'],
    :g4e => ['7450', '4bd546f39c016ff453e9183b6e2485c5e72b11b2'],
    # There aren't separate 32/64-bit binaries
    :g5 => ['G5', '6e2ed867bf8b8bea9d71244772bc8e3463cc245a'],
    :g5_64 => ['G5', '6e2ed867bf8b8bea9d71244772bc8e3463cc245a']
  }

  # Formula needs a URL and sha1 even if it can't be installed
  prefix, sh1 = urls[Hardware::CPU.family] || urls[:g3]

  url urlbase+version+'/TenFourFox'+prefix+'-'+version+'.app.zip'
  sha1 sh1

  def install
    prefix.install Dir['TenFourFox*.app']
  end
end
