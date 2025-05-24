class Ccat < Formula
  desc "Like cat but displays content with syntax highlighting"
  homepage "https://github.com/jingweno/ccat"
  url "https://github.com/jingweno/ccat/archive/v1.0.0.tar.gz"
  sha256 "5bd558009a9054ff25f3d023d67080c211354d1552ffe377ce11d49376fb4aee"


  conflicts_with "ccrypt", :because => "both install `ccat` binaries"

  depends_on "go" => :build

  def install
    system "./script/build"
    bin.install "ccat"
  end

  test do
    (testpath/"test.txt").write <<-EOS.undent
      I am a colourful cat
    EOS

    assert_match(/I am a colourful cat/, shell_output("#{bin}/ccat test.txt"))
  end
end
