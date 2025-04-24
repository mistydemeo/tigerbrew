class Syntaxerl < Formula
  homepage "https://github.com/ten0s/syntaxerl"
  desc "Syntax checker for Erlang code and config files"
  url "https://github.com/ten0s/syntaxerl/archive/0.13.0.tar.gz"
  sha256 "1788525472fea5b0139175abbfaeddcf7f94a875d42d5d3f0d4332f3803f1b11"

  depends_on "erlang"

  def install
    system "make"
    bin.install "syntaxerl"
  end

  test do
    (testpath/"app.config").write "[{app,[{arg1,1},{arg2,2}]}]."
    assert_equal "", shell_output("#{bin}/syntaxerl #{testpath}/app.config")

    (testpath/"invalid.config").write "]["
    assert_match /invalid.config:1: syntax error before: '\]'/, shell_output("#{bin}/syntaxerl #{testpath}/invalid.config")
  end
end
