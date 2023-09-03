require 'formula'

class Tenfourfox < Formula
  homepage 'http://www.floodgap.com/software/tenfourfox/'
  urlbase = 'https://downloads.sourceforge.net/tenfourfox/'
  version '32.5.0-fpr'

  # depends_on :arch => :ppc

  urls = {
    :g3 => ['G3', '528641f72195017e957690d3c12afcd0f3483993369ab015340fd07fa3c79dec'],
    :g4 => ['7400', '07296a9e6c50fc91ab07374186c3e6c854f6274fc7fb8ad99caf74224d30d6b0'],
    :g4e => ['7450', 'e475daffc4a9e41252d36b901f591330c3c805480376c77fc53b018ae348dae7'],
    # There aren't separate 32/64-bit binaries
    :g5 => ['G5', 'c3865071433ea27724a6c971021be58eb33846e05c55e23d6a66f2db381dda2a'],
    :g5_64 => ['G5', 'c3865071433ea27724a6c971021be58eb33846e05c55e23d6a66f2db381dda2a']
  }

  # Formula needs a URL and sha1 even if it can't be installed
  prefix, sh2 = urls[Hardware::CPU.family] || urls[:g3]

  url urlbase+'fpr32.5'+'/TenFourFox'+prefix+'-FPR32.5.app.zip'
  sha256 sh2

  def install
    prefix.install Dir['TenFourFox*.app']
  end
end
