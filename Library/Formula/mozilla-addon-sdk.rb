class MozillaAddonSdk < Formula
  desc "Create Firefox add-ons using JS, HTML, and CSS"
  homepage "https://wiki.mozilla.org/Jetpack"
  url "http://ftp.mozilla.org/pub/mozilla.org/labs/jetpack/addon-sdk-1.17.zip"
  sha256 "16e29d92214a556c8422db156b541fb8c47addfcb3cd879e0a4ca879d6a31f65"

  def install
    libexec.install Dir["*"]
    bin.install_symlink "#{libexec}/bin/cfx"
  end
end
