class Cloc < Formula
  desc "Statistics utility to count lines of code"
  homepage "http://cloc.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/cloc/cloc/v1.64/cloc-1.64.pl"
  sha256 "79edea7ea1f442b1632001e23418193ae4571810e60de8bd25e491036d60eb3d"


  def install
    bin.install "cloc-#{version}.pl" => "cloc"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <stdio.h>
      int main(void) {
        return 0;
      }
    EOS

    assert_match "1,C,0,0,4", shell_output("#{bin}/cloc --csv .")
  end
end
