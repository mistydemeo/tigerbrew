class Lib3ds < Formula
  desc "Library for managing 3D-Studio Release 3 and 4 '.3DS' files"
  homepage "https://code.google.com/p/lib3ds/"
  url "https://lib3ds.googlecode.com/files/lib3ds-1.3.0.zip"
  sha256 "f5b00c302955a67fa5fb1f2d3f2583767cdc61fdbc6fd843c0c7c9d95c5629e3"


  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make", "install"
  end

  test do
    # create a raw emtpy 3ds file.
    (testpath/"test.3ds").write("\x4d\x4d\x06\x00\x00\x00")
    system "#{bin}/3dsdump", "test.3ds"
  end
end
