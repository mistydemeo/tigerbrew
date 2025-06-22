class Daemon < Formula
  desc "Turn other processes into daemons"
  homepage "https://libslack.org/daemon/"
  url "http://libslack.org/daemon/download/daemon-0.6.4.tar.gz"
  sha256 "c4b9ea4aa74d55ea618c34f1e02c080ddf368549037cb239ee60c83191035ca1"

  # fixes for mavericks strlcpy/strlcat: https://trac.macports.org/ticket/42845
  patch do
    url "https://gist.githubusercontent.com/jacobsa/b86cf524156ca10c54e1/raw/91dae330611c96ecb55b26e07e905ab2279258f0/daemon-0.6.4-ignore-strlcpy-strlcat.patch"
    sha256 "a56e16b0801a13045d388ce7e755b2b4e40288c3731ce0f92ea879d0871782c0"
  end if MacOS.version >= :mavericks

  def install
    system "./config"
    system "make"
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    system "#{bin}/daemon", "--version"
  end
end
