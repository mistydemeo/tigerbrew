class GitSubrepo < Formula
  desc "Git Submodule Alternative"
  homepage "https://github.com/ingydotnet/git-subrepo"
  url "https://github.com/ingydotnet/git-subrepo/archive/0.2.3.tar.gz"
  sha256 "c0db888e841e06ae6f5c74dc9bde4e7ef33ce31b46caeb504885d5b85df1ceef"
  head "https://github.com/ingydotnet/git-subrepo.git"


  def install
    mkdir_p libexec
    system "make", "PREFIX=#{prefix}", "INSTALL_LIB=#{libexec}", "install"
    bin.install_symlink libexec/"git-subrepo"
  end

  test do
    mkdir "mod" do
      system "git", "init"
      touch "HELLO"
      system "git", "add", "HELLO"
      system "git", "commit", "-m", "testing"
    end

    mkdir "container" do
      system "git", "init"
      touch ".gitignore"
      system "git", "add", ".gitignore"
      system "git", "commit", "-m", "testing"

      assert_match(/cloned into/,
                   shell_output("git subrepo clone ../mod mod"))
    end
  end
end
