class Graphite2 < Formula
  desc "Smart font renderer for non-Roman scripts"
  homepage "https://scripts.sil.org/cms/scripts/page.php?site_id=projects&item_id=graphite_home"
  url "https://downloads.sourceforge.net/project/silgraphite/graphite2/graphite2-1.3.2.tgz"
  sha256 "97af064ff07828f8724b5a9c27d63e2df5aef69a742f0f67cc3f68c3f15d3850"


  depends_on "cmake" => :build

  resource "testfont" do
    url "https://scripts.sil.org/pub/woff/fonts/Simple-Graphite-Font.ttf"
    sha256 "7e573896bbb40088b3a8490f83d6828fb0fd0920ac4ccdfdd7edb804e852186a"
  end

  def install
    system "cmake", *std_cmake_args
    system "make", "install"
  end

  test do
    resource("testfont").stage do
      shape = shell_output("#{bin}/gr2fonttest Simple-Graphite-Font.ttf 'abcde'")
      assert_match /67.*36.*37.*38.*71/m, shape
    end
  end
end
