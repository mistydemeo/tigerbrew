class Rkflashtool < Formula
  desc "Tools for flashing Rockchip devices"
  homepage "https://sourceforge.net/projects/rkflashtool/"
  url "https://downloads.sourceforge.net/project/rkflashtool/rkflashtool-5.1/rkflashtool-5.1-src.tar.bz2"
  sha256 "2cad0e0c116357b721a6ac98fb3a91b43fe0269cda66e75eda4adec3330b7735"

  head "git://git.code.sf.net/p/rkflashtool/Git"


  depends_on "libusb"

  # Add file 'version.h' that has been forgotten in the tarball
  resource "version" do
    url "https://downloads.sourceforge.net/project/rkflashtool/rkflashtool-5.1/version.h"
    sha256 "b7bd8e3c66170d5f6e6a68c5add677ad365e37b4121251de87ad29e7fdf06cd6"
  end

  def install
    resource("version").stage { buildpath.install "version.h" } if build.stable?
    system "make"

    # No 'install' method found in Makefile
    bin.install "rkflashtool", "rkcrc", "rkmisc", "rkpad",
      "rkparameters", "rkparametersblock", "rkunpack", "rkunsign"
  end

  test do
    (testpath/"input.file").write "ABCD"
    system bin/"rkcrc", "input.file", "output.file"
    result = shell_output("cat output.file")
    result.force_encoding("UTF-8") if result.respond_to?(:force_encoding)
    assert_equal "ABCD\264\366\a\t", result
  end
end
