class Libharu < Formula
  desc "Library for generating PDF files"
  homepage "http://www.libharu.org/"
  url "https://github.com/libharu/libharu/archive/RELEASE_2_3_0.tar.gz"
  sha256 "8f9e68cc5d5f7d53d1bc61a1ed876add1faf4f91070dbc360d8b259f46d9a4d2"
  head "https://github.com/libharu/libharu.git"


  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "libpng"

  def install
    system "./buildconf.sh", "--force"

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --with-png=#{Formula["libpng"].opt_prefix}
    ]

    args << "--with-zlib=#{MacOS.sdk_path}/usr" unless MacOS::CLT.installed?

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include "hpdf.h"

      int main(void)
      {
        int result = 1;
        HPDF_Doc pdf = HPDF_New(NULL, NULL);

        if (pdf) {
          HPDF_AddPage(pdf);

          if (HPDF_SaveToFile(pdf, "test.pdf") == HPDF_OK)
            result = 0;

          HPDF_Free(pdf);
        }

        return result;
      }
    EOS
    system ENV.cc, "test.c", "-lhpdf", "-lz", "-o", "test"
    system "./test"
  end
end
