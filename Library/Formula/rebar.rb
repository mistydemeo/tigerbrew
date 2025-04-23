class Rebar < Formula
  desc "Erlang build tool"
  homepage "https://github.com/rebar/rebar"
  url "https://github.com/rebar/rebar/archive/2.6.4.tar.gz"
  sha256 "577246bafa2eb2b2c3f1d0c157408650446884555bf87901508ce71d5cc0bd07"

  head "https://github.com/rebar/rebar.git"

  bottle do
  end

  depends_on "erlang"

  def install
    system "./bootstrap"
    bin.install "rebar"
  end

  test do
    system bin/"rebar", "--version"
  end
end
