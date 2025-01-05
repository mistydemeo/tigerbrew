class OpenVcdiff < Formula
  desc "Encoder/decoder for the VCDIFF (RFC3284) format"
  homepage "https://github.com/google/open-vcdiff"
  url "https://drive.google.com/uc?id=0B5WpIi2fQU1aNGJwVE9hUjU5clU&export=download"
  version "0.8.4"
  sha256 "2b142b1027fb0a62c41347600e01a53fa274dad15445a7da48083c830c3138b3"

  bottle do
    sha256 "c0570dc0989d404f31e3d5ddc26ca1f77f47d01075a9e1c87138e76143f3604b" => :tiger_altivec
  end

  def install
    system "./configure", "CPPFLAGS=-DGTEST_USE_OWN_TR1_TUPLE=1",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <google/vcdecoder.h>
      int main()
      {
        open_vcdiff::VCDiffDecoder decoder;
        return 0;
      }
    EOS
    system ENV.cxx, "-I#{include}", "-L#{lib}", "-lvcddec", "-lvcdcom",
           testpath/"test.cpp", "-o", "test"
    system "./test"
  end
end
