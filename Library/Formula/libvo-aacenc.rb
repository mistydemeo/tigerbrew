class LibvoAacenc < Formula
  desc "VisualOn AAC encoder library"
  homepage "http://opencore-amr.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/opencore-amr/vo-aacenc/vo-aacenc-0.1.3.tar.gz"
  sha256 "e51a7477a359f18df7c4f82d195dab4e14e7414cbd48cf79cc195fc446850f36"

  bottle do
    cellar :any
    sha1 "db988fca9280de51d16bddcf04bd22e9b3422b58" => :tiger_altivec
    sha1 "b75add72a8f671b9fbfeeeb0e5335a7e08adcc05" => :leopard_g3
    sha1 "1028521d75673ce18bc33018598e3a09b2aeee36" => :leopard_altivec
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
