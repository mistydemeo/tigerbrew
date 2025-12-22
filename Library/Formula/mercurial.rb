# No head build supported; if you need head builds of Mercurial, do so outside
# of Homebrew.
class Mercurial < Formula
  desc "Scalable distributed version control system"
  homepage "https://www.mercurial-scm.org/"
  url "https://www.mercurial-scm.org/release/mercurial-6.9.tar.gz"
  sha256 "629604293df2be8171ec856bf4f8b4faa8e4305af13607dce0f89f74132836d6"
  license "GPL-2.0-or-later"

  bottle do
    sha256 "5f8bbcb62300dcfa8d8c7def95afea47eed5abf89c5d830b8d590a7941af6a85" => :tiger_altivec
    sha256 "46e18cbaf4e79521aa08d824550a9b1b5a1712d3a0572a53925cc1ff27471175" => :tiger_g3
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
