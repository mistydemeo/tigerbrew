class Xvid < Formula
  desc "High-performance, high-quality MPEG-4 video library"
  homepage "https://www.xvid.org"
  url "https://fossies.org/unix/privat/xvidcore-1.3.4.tar.gz"
  # Official download takes a long time to fail, so set it as the mirror for now
  mirror "http://downloads.xvid.org/downloads/xvidcore-1.3.4.tar.gz"
  sha256 "4e9fd62728885855bc5007fe1be58df42e5e274497591fec37249e1052ae316f"

  bottle do
    cellar :any
    sha256 "ec7422d4b91dd4b4df077b62c570ae69c81631f07e4cbb0a4c399743cd086f67" => :tiger_altivec
    sha256 "6a4338ba070c5512b0607d44587df14ffb5f6b28c7463044ec034e1dd46e64b9" => :leopard_g3
    sha256 "2555cd6f7798940b32ba3f0b1f52c04362e6438f2fa56f3aca79369730504e6c" => :leopard_altivec
  end

  def install
    cd "build/generic" do
      system "./configure", "--disable-assembly", "--prefix=#{prefix}"
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
    system ENV.cc, "test.cpp", "-L#{lib}", "-lxvidcore", "-o", "test"
    system "./test"
  end
end
