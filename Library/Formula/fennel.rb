class Fennel < Formula
  desc "Lua Lisp Language"
  homepage "https://fennel-lang.org"
  url "https://github.com/bakpakin/Fennel/archive/1.3.1.tar.gz"
  sha256 "12045cbd70088b966e73ac4c54ad63e096fb9b91b9874cb17533c8045595ee74"
  license "MIT"

  bottle do
    cellar :any_skip_relocation
    sha256 "1df9168b5ed9f68a98c9c5cd67798aefeb33a01fda717e86a4a4bb4188b0f650" => :tiger_g3
    sha256 "1df9168b5ed9f68a98c9c5cd67798aefeb33a01fda717e86a4a4bb4188b0f650" => :tiger_altivec
  end

  depends_on "lua"

  def install
    system "make"
    bin.install "fennel"

    lua = Formula["lua"]
    (share/"lua"/"5.4").install "fennel.lua"
  end

  test do
    assert_match "hello, world!", shell_output("#{bin}/fennel -e '(print \"hello, world!\")'")
  end
end
