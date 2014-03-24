require 'formula'

class HerokuToolbelt < Formula
  homepage 'https://toolbelt.heroku.com/other'
  url 'http://assets.heroku.com.s3.amazonaws.com/heroku-client/heroku-client-3.3.0.tgz'
  sha1 '5c4760414623b3e92bb0deaf5d49da695f8c7ad4'

  # Not compatible with ruby pre-1.9.1 or so, due to requiring
  # securerandom and json in the stdlib
  depends_on 'ruby'

  def install
    inreplace 'bin/heroku', '/usr/bin/env ruby', Formula['ruby'].opt_bin/'ruby'
    libexec.install Dir["*"]
    bin.write_exec_script libexec/"bin/heroku"
  end

  test do
    system "#{bin}/heroku", "version"
  end
end
