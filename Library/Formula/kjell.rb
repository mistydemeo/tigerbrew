class Kjell < Formula
  desc "Erlang shell"
  homepage "https://karlll.github.io/kjell/"
  # clone repository in order to get extensions submodule
  url "https://github.com/karlll/kjell.git",
      :tag => "0.2.6",
      :revision => "0848ad2d2ddefc74774f0d793f4aebd260efb052"

  head "https://github.com/karlll/kjell.git"


  depends_on "erlang"

  def install
    system "make"
    system "make", "configure", "PREFIX=#{prefix}"
    system "make", "install", "NO_SYMLINK=1"
    system "make", "install-extensions"
  end

  def caveats; <<-EOS.undent
    Extension 'kjell-prompt' requires a powerline patched font.
    See https://github.com/Lokaltog/powerline-fonts
    EOS
  end

  test do
    ENV["TERM"] = "xterm"
    system "script", "-q", "/dev/null", bin/"kjell", "-sanity_check", "true"
  end
end
