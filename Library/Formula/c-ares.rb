class CAres < Formula
  desc "Asynchronous DNS library"
  homepage "https://c-ares.org/"
  url "https://c-ares.org/download/c-ares-1.27.0.tar.gz"
  mirror "https://github.com/c-ares/c-ares/releases/download/cares-1_27_0/c-ares-1.27.0.tar.gz"
  sha256 "0a72be66959955c43e2af2fbd03418e82a2bd5464604ec9a62147e37aceb420b"
  head "https://github.com/bagder/c-ares.git"

  bottle do
    sha256 "8fd582e129e7a3d1bbbb6df8c4d7dcb3189ba7ce8406ef96091dfa8cb90de478" => :tiger_altivec
  end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-debug"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <stdio.h>
      #include <ares.h>

      int main()
      {
        ares_library_init(ARES_LIB_INIT_ALL);
        ares_library_cleanup();
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lcares", "-o", "test"
    system "./test"
  end
end
