class Admesh < Formula
  desc "Processes triangulated solid meshes"
  homepage "https://github.com/admesh/admesh"
  url "https://github.com/admesh/admesh/releases/download/v0.98.2/admesh-0.98.2.tar.gz"
  sha256 "ae34a6f42136a434ae242dcd76415dca326ecd1fe55bbd253bb56318ceee382b"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    # Test file is the beginning of block.stl from admesh's source
    (testpath/"test.stl").write <<-EOS.undent
      SOLID Untitled1
      FACET NORMAL  0.00000000E+00  0.00000000E+00  1.00000000E+00
      OUTER LOOP
      VERTEX -1.96850394E+00  1.96850394E+00  1.96850394E+00
      VERTEX -1.96850394E+00 -1.96850394E+00  1.96850394E+00
      VERTEX  1.96850394E+00 -1.96850394E+00  1.96850394E+00
      ENDLOOP
      ENDFACET
      ENDSOLID Untitled1
    EOS
    system "admesh", "test.stl"
  end
end
