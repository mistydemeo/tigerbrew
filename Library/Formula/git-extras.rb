class GitExtras < Formula
  desc "Small git utilities"
  homepage "https://github.com/tj/git-extras"
  url "https://github.com/tj/git-extras/archive/3.0.0.tar.gz"
  sha256 "490742428824d6e807e894c3b6612be37a9a9a4e8fbea747d1813e5d62b2a807"
  head "https://github.com/tj/git-extras.git"


  def install
    inreplace "Makefile", %r{\$\(DESTDIR\)(?=/etc/bash_completion\.d)}, "$(DESTDIR)$(PREFIX)"
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    system "git", "init"
    assert_match /#{testpath}/, shell_output("#{bin}/git-root")
  end
end
