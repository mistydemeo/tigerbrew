class Ilmbase < Formula
  desc "OpenEXR ILM Base libraries (high dynamic-range image file format)"
  homepage "http://www.openexr.com/"
  url "http://download.savannah.nongnu.org/releases/openexr/ilmbase-2.2.0.tar.gz"
  mirror "http://download-mirror.savannah.gnu.org/releases/openexr/ilmbase-2.2.0.tar.gz"
  sha256 "ecf815b60695555c1fbc73679e84c7c9902f4e8faa6e8000d2f905b8b86cedc7"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
    (share/"ilmbase").install %W[Half HalfTest Iex IexMath IexTest IlmThread Imath ImathTest]
  end

  test do
    cd share/"ilmbase/IexTest" do
      system ENV.cxx, "-I#{include}/OpenEXR", "-I./", "-c",
             "testBaseExc.cpp", "-o", testpath/"test"
    end
  end
end
