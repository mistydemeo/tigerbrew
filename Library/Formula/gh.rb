class Gh < Formula
  desc "GitHub command-line client"
  homepage "https://github.com/jingweno/gh"
  url "https://github.com/jingweno/gh/archive/v2.1.0.tar.gz"
  sha256 "3435c95e78c71589c983e2cafa8948e1abf73aaa033e7fb9d891c052ce25f4f3"
  head "https://github.com/jingweno/gh.git"


  depends_on "go" => :build

  option "without-completions", "Disable bash/zsh completions"

  def install
    system "script/make", "--no-update"
    bin.install "gh"
    man1.install "man/gh.1"

    if build.with? "completions"
      bash_completion.install "etc/gh.bash_completion.sh"
      zsh_completion.install "etc/gh.zsh_completion" => "_gh"
    end
  end

  test do
    HOMEBREW_REPOSITORY.cd do
      assert_equal "bin/brew", `#{bin}/gh ls-files -- bin`.strip
    end
  end
end
