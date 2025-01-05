class Xvid < Formula
  desc "High-performance, high-quality MPEG-4 video library"
  homepage "https://labs.xvid.com"
  url "https://downloads.xvid.com/downloads/xvidcore-1.3.7.tar.gz"
  mirror "https://fossies.org/linux/misc/xvidcore-1.3.7.tar.gz"
  sha256 "abbdcbd39555691dd1c9b4d08f0a031376a3b211652c0d8b3b8aa9be1303ce2d"
  license "GPL-2.0-or-later"

  bottle do
  end

  def install
    cd "build/generic" do
      system "./configure", "--prefix=#{prefix}"
      ENV.j1 # Or make fails
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <xvid.h>
      #define NULL 0
      int main() {
        xvid_gbl_init_t xvid_gbl_init;
        xvid_global(NULL, XVID_GBL_INIT, &xvid_gbl_init, NULL);
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-L#{lib}", "-lxvidcore", "-o", "test"
    system "./test"
  end
end
