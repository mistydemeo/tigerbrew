require 'formula'

class Tenfourfox < Formula
  homepage 'http://www.floodgap.com/software/tenfourfox/'
  urlbase = 'https://downloads.sourceforge.net/tenfourfox/'
  version '24.4.0'

  depends_on :arch => :ppc

  urls = {
    :g3 => ['G3', '3a1c28b2c203d1d832028184efc15f48679cbb6f'],
    :g4 => ['7400', '1c3bcf7b47e77de9184c63a3f150b3cb53d1ef32'],
    :g4e => ['7450', '720eaec75df7ad6a95d4ebe94ad178b1861ac146'],
    # There aren't separate 32/64-bit binaries
    :g5 => ['G5', '3136fb68a05ade518359f537b4bb1927827a86e7'],
    :g5_64 => ['G5', '3136fb68a05ade518359f537b4bb1927827a86e7']
  }

  # Formula needs a URL and sha1 even if it can't be installed
  prefix, sh1 = urls[Hardware::CPU.family] || urls[:g3]

  url urlbase+version+'/TenFourFox'+prefix+'-'+version+'.app.zip'
  sha1 sh1

  devel do
    version '22.0.1'
    urls = {
      :g3 => ['G3', '5763489450e835d558f128f622f030a7e944ca7c'],
      :g4 => ['7400', '663e2f7acd42decd01def4ac11c8d839f8659f81'],
      :g4e => ['7450', '044692f35c30384634ec4589a5c76bd7f2311b85'],
      :g5 => ['G5', '90cb141bd7a126eadca941f1be6ae5daa32a8366']
    }

    prefix, sh1 = urls[Hardware::CPU.family] || urls[:g3]

    url urlbase+prefix+'-'+version+'.app.zip'
    sha1 sh1
  end

  def install
    prefix.install Dir['../*.app']
  end

  def caveats; <<-EOS.undent
    After installation, run `brew linkapps` to link
    TenFourFox into your ~/Applications folder.
    EOS
  end
end
