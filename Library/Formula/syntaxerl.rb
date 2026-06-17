class Syntaxerl < Formula
  homepage "https://github.com/ten0s/syntaxerl"
  desc "Syntax checker for Erlang code and config files"
  url "https://github.com/ten0s/syntaxerl/archive/0.15.0.tar.gz"
  sha256 "61d2d58e87a7a5eab1f58c5857b1a9c84a091d18cd683385258c3c0d7256eb64"

  depends_on "erlang"
  depends_on "rebar3" => :build

  def install
    system "make"
    bin.install "_build/default/bin/syntaxerl"
  end

  test do
    (testpath/"app.config").write "[{app,[{arg1,1},{arg2,2}]}]."
    assert_equal "", pipe_output("#{bin}/syntaxerl #{testpath}/app.config")

    (testpath/"invalid.config").write "]["
    assert_match "/invalid.config:1: syntax error before: ']'", pipe_output("#{bin}/syntaxerl #{testpath}/invalid.config")
  end
end
