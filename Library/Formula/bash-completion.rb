class BashCompletion < Formula
  desc "Programmable bash completion"
  homepage "https://github.com/scop/bash-completion"
  url "https://github.com/scop/bash-completion/releases/download/2.11/bash-completion-2.11.tar.xz"
  sha256 "73a8894bad94dee83ab468fa09f628daffd567e8bef1a24277f1e9a0daf911ac"

  bottle do
    cellar :any_skip_relocation
    sha256 "b6a0ef1ac25ab53f37f73d1fb16646d64189f92cbd413d33e09fd8fb46a002a6" => :tiger_altivec
  end

  # bash-completion 2.x needs Bash 4.x minimum
  # Grab a bash 4.3 binary which fixes shellshock from TenFourFox project page
  # https://sourceforge.net/projects/tenfourfox/files/tools/
  # and replace /bin/sh, /bin/bash if you want to use bash-completion with those shells.
  # https://tenfourfox.blogspot.com/2014/09/bashing-bash-updated-powerpc-os-x-bash.html
  depends_on "bash"

  def compdir
    etc/"bash_completion.d"
  end

  def install
    inreplace "bash_completion" do |s|
      s.gsub! "/etc/bash_completion", etc/"bash_completion"
      s.gsub! "readlink -f", "readlink"
    end

    system "./configure", "--prefix=#{prefix}"
    system "make", "install"

    unless (compdir/"brew_bash_completion.sh").exist?
      compdir.install_symlink HOMEBREW_CONTRIB/"brew_bash_completion.sh"
    end
  end

  def caveats; <<-EOS.undent
    Add the following lines to your ~/.bash_profile:
      if [ -f $(brew --prefix)/etc/bash_completion ]; then
        . $(brew --prefix)/etc/bash_completion
      fi

    Homebrew's own bash completion script has been installed to
      #{compdir}
    EOS
  end
end
