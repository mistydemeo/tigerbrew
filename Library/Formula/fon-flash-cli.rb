class FonFlashCli < Formula
  desc "Flash La Fonera and Atheros chipset compatible devices"
  homepage "https://www.gargoyle-router.com/wiki/doku.php?id=fon_flash"
  url "https://www.gargoyle-router.com/downloads/src/gargoyle_1.8.0-src.tar.gz"
  version "1.8.0"
  sha256 "89493cfedbe38800121fbe5e281e0542df4026f76de242ef664120649900772a"

  head "https://github.com/ericpaulbishop/gargoyle.git"


  def install
    cd "fon-flash" do
      system "make", "fon-flash"
      bin.install "fon-flash"
    end
  end

  test do
    system "#{bin}/fon-flash"
  end
end
