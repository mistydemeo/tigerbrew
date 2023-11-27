# No head build supported; if you need head builds of Mercurial, do so outside
# of Homebrew.
class Mercurial < Formula
  desc "Scalable distributed version control system"
  homepage "https://www.mercurial-scm.org/"
  url "https://www.mercurial-scm.org/release/mercurial-6.6.tar.gz"
  sha256 "6bfd71cba0df3b18de424216b30e2a541cca6e0104853d3334be80a2ab09a4ad"
  license "GPL-2.0-or-later"

  bottle do
    cellar :any_skip_relocation
    sha256 "c9a73ff32f4eaca7570a489d862f73a0eb10bfdbc91fe4518231090989bcbf6b" => :tiger_altivec
  end

  depends_on :python3
  depends_on "gettext" => :build

  def install
    ENV.minimal_optimization if MacOS.version <= :snow_leopard
    # GCC 4.0 doesn't support granular error settings, so the build breaks
    inreplace "setup.py", "-Werror=declaration-after-statement", "-Werror"

    system "make", "PREFIX=#{prefix}", "install-bin"
    # Install man pages, which come pre-built in source releases
    man1.install "doc/hg.1"
    man5.install "doc/hgignore.5", "doc/hgrc.5"

    # install the completion scripts
    bash_completion.install "contrib/bash_completion" => "hg-completion.bash"
    zsh_completion.install "contrib/zsh_completion" => "_hg"
  end

  test do
    system "#{bin}/hg", "init"
  end
end
