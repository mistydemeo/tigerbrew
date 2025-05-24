class SfPwgen < Formula
  desc "Generate passwords using SecurityFoundation framework"
  homepage "https://bitbucket.org/anders/sf-pwgen/"
  url "https://bitbucket.org/anders/sf-pwgen/downloads/sf-pwgen-1.3.tar.gz"
  sha256 "0489dace9de7ad65bf545e774dbf67b6d24cecdcbd32fe5d41397140ccf3aa84"

  head "https://bitbucket.org/anders/sf-pwgen", :using => :hg


  depends_on :macos => :mountain_lion

  def install
    system "make"
    bin.install "sf-pwgen"
  end

  test do
    assert_equal 20, shell_output("#{bin}/sf-pwgen -a memorable -c 1 -l 20").chomp.length
  end
end
