class GitStree < Formula
  desc "Git subtree helper command"
  homepage "https://github.com/tdd/git-stree"
  head "https://github.com/tdd/git-stree.git"
  url "https://github.com/tdd/git-stree/archive/0.4.5.tar.gz"
  sha256 "5504ac90871c73c92c21f5cd84b0bf956c521b237749e2b2dd699dbe0c096af8"


  def install
    bin.install "git-stree"
    bash_completion.install "git-stree-completion.bash" => "git-stree"
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

      system "git", "stree", "add", "mod", "-P", "mod", "../mod"
    end
  end
end
