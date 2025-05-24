class GitCrypt < Formula
  desc "Enable transparent encryption/decryption of files in a git repo"
  homepage "https://www.agwa.name/projects/git-crypt/"
  url "https://www.agwa.name/projects/git-crypt/downloads/git-crypt-0.5.0.tar.gz"
  sha256 "0a8f92c0a0a125bf768d0c054d947ca4e4b8d6556454b0e7e87fb907ee17cf06"


  depends_on "openssl"

  def install
    system "make"
    bin.install "git-crypt"
  end

  test do
    system "#{bin}/git-crypt", "keygen", "keyfile"
  end
end
