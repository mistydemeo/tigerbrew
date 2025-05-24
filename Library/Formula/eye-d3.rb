class EyeD3 < Formula
  desc "Work with ID3 metadata in .mp3 files"
  homepage "http://eyed3.nicfit.net/"
  url "http://eyed3.nicfit.net/releases/eyeD3-0.7.8.tar.gz"
  sha256 "06b956572b8d63c52db8f62447277a5647fc185b7afef9f2a918b4601db467db"


  depends_on :python if MacOS.version <= :snow_leopard

  # Looking for documentation? Please submit a PR to build some!
  # See https://github.com/Homebrew/homebrew/issues/32770 for previous attempt.

  def install
    # Install in our prefix, not the first-in-the-path python site-packages dir.
    ENV.prepend_create_path "PYTHONPATH", libexec+"lib/python2.7/site-packages"

    system "python", "setup.py", "install", "--prefix=#{libexec}"
    share.install "docs/plugins", "docs/api", "docs/cli.rst"

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec+"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    touch "temp.mp3"
    system "#{bin}/eyeD3", "-a", "HomebrewYo", "-n", "37", "temp.mp3"
  end
end
