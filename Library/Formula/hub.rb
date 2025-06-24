class Hub < Formula
  desc "Add GitHub support to git on the command-line"
  homepage "https://hub.github.com/"
  url "https://github.com/github/hub/archive/v2.2.1.tar.gz"
  sha256 "9350aba6a8e3da9d26b7258a4020bf84491af69595f7484f922d75fc8b86dc10"
  head "https://github.com/github/hub.git"


  # rake wasn't shipped with Ruby back in 1.8.2
  depends_on :macos => :leopard

  option "without-completions", "Disable bash/zsh completions"

  depends_on "go" => :build

  def install
    system "script/build"
    bin.install "hub"
    man1.install Dir["man/*"]

    if build.with? "completions"
      bash_completion.install "etc/hub.bash_completion.sh"
      zsh_completion.install "etc/hub.zsh_completion" => "_hub"
    end
  end

  test do
    HOMEBREW_REPOSITORY.cd do
      assert_equal "bin/brew", shell_output("#{bin}/hub ls-files -- bin").strip
    end
  end
end
