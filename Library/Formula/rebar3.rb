class Rebar3 < Formula
  desc "Erlang build tool"
  homepage "https://rebar3.org/"
  url "https://github.com/erlang/rebar3/archive/refs/tags/3.20.0.tar.gz"
  sha256 "53ed7f294a8b8fb4d7d75988c69194943831c104d39832a1fa30307b1a8593de"

  head "https://github.com/erlang/rebar3.git"

  bottle do
  end

  depends_on "erlang"

  def install
    system "./bootstrap"
    bin.install "rebar3"
  end

  test do
    system bin/"rebar3", "--version"
  end
end
