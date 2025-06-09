class LibvoAacenc < Formula
  desc "VisualOn AAC encoder library"
  homepage "https://opencore-amr.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/opencore-amr/vo-aacenc/vo-aacenc-0.1.3.tar.gz"
  sha256 "e51a7477a359f18df7c4f82d195dab4e14e7414cbd48cf79cc195fc446850f36"

  bottle do
    cellar :any
    sha256 "cc1f30fc2ebcf4d2197c17ad6dd8874ef922232929d1042bdb0611b53236fe78" => :tiger_altivec
    sha256 "050d5885633b5cc5d050ce432dc0be0d96553eaf74280e6d0fd2c3c11be58433" => :leopard_g3
    sha256 "9825387b4c10d94aab5f13f94150021062a9077956f4d038124f1aca28f9c094" => :leopard_altivec
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <vo-aacenc/cmnMemory.h>

      int main()
      {
        VO_MEM_INFO info; info.Size = 1;
        VO_S32 uid = 0;
        VO_PTR pMem = cmnMemAlloc(uid, &info);
        cmnMemFree(uid, pMem);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-lvo-aacenc", "-o", "test"
    system "./test"
  end
end
