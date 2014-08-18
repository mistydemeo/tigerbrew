require 'formula'

class Tenfourfox < Formula
  homepage 'http://www.floodgap.com/software/tenfourfox/'
  urlbase = 'https://downloads.sourceforge.net/tenfourfox/'
  version '31.0.0'

  # depends_on :arch => :ppc

  urls = {
    :g3 => ['G3', '6443902f14010ad87c75014efb7f9573ffe6799b'],
    :g4 => ['7400', '9d8e6b6e7701fde539fa01f5f3a5ec79bf7b753d'],
    :g4e => ['7450', '831a6df1290edaf27faad06e9070e40ba065deaa'],
    # There aren't separate 32/64-bit binaries
    :g5 => ['G5', '6881dd3295a544ca9e62c44bdf42555b0e6beaed'],
    :g5_64 => ['G5', '6881dd3295a544ca9e62c44bdf42555b0e6beaed']
  }

  # Formula needs a URL and sha1 even if it can't be installed
  prefix, sh1 = urls[Hardware::CPU.family] || urls[:g3]

  url urlbase+version+'/TenFourFox'+prefix+'-31.0.app.zip'
  sha1 sh1

  def install
    prefix.install Dir['TenFourFox*.app']
  end
end
