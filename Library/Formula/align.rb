class Align < Formula
  desc "Text column alignment filter"
  homepage "http://www.cs.indiana.edu/~kinzler/align/"
  url "http://www.cs.indiana.edu/~kinzler/align/align-1.7.4.tgz"
  sha256 "4775cc92bd7d5d991b32ff360ab74cfdede06c211def2227d092a5a0108c1f03"


  def install
    system "make", "install", "BINDIR=#{bin}"
  end

  test do
    assert_equal " 1  1\n12 12\n", pipe_output(bin/"align", "1 1\n12 12\n")
  end
end
