class Wrk < Formula
  desc "HTTP benchmarking tool"
  homepage "https://github.com/wg/wrk"
  url "https://github.com/wg/wrk/archive/4.0.1.tar.gz"
  sha256 "c03bbc283836cb4b706eb6bfd18e724a8ce475e2c16154c13c6323a845b4327d"
  head "https://github.com/wg/wrk.git"


  depends_on "openssl"

  conflicts_with "wrk-trello", :because => "both install `wrk` binaries"

  def install
    ENV.j1
    system "make"
    bin.install "wrk"
  end

  test do
    system *%W[#{bin}/wrk -c 1 -t 1 -d 1 http://example.com/]
  end
end
