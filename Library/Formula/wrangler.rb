class Wrangler < Formula
  desc "Refactoring tool for Erlang with emacs and Eclipse integration"
  homepage "https://refactoringtools.github.io/wrangler/"
  url "https://github.com/RefactoringTools/wrangler/archive/wrangler1.2.tar.gz"
  sha256 "a6a87ad0513b95bf208c660d112b77ae1951266b7b4b60d8a2a6da7159310b87"

  depends_on "erlang"

  def install
    ENV.deparallelize
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end
