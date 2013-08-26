require 'formula'

class Tenfourfox < Formula
  homepage 'http://www.floodgap.com/software/tenfourfox/'
  urlbase = 'https://tenfourfox.googlecode.com/files/TenFourFox'
  version '17.0.8'

  depends_on :arch => :ppc

  urls = {
    :g3 => ['G3', 'de4b8f748ee45fb79eeb7ddefc76d86358c75c73'],
    :g4 => ['7400', '6796698a20544674192eff9d1b43116a5482444a'],
    :g4e => ['7450', '25b24609cce270a52c403894194f31c81e481e5f'],
    :g5 => ['G5', '6e87393f681c0e0b17eb27b6f1f97a7242d0ae4b']
  }

  # Formula needs a URL and sha1 even if it can't be installed
  prefix, sh1 = urls[Hardware::CPU.family] || urls[:g3]

  url urlbase+prefix+'-'+version+'.app.zip'
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
