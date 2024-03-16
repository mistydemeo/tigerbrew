class CAres < Formula
  desc "Asynchronous DNS library"
  homepage "http://c-ares.haxx.se/"
  url "https://c-ares.org/download/c-ares-1.27.0.tar.gz"
  mirror "https://github.com/c-ares/c-ares/releases/download/cares-1_27_0/c-ares-1.27.0.tar.gz"
  sha256 "0a72be66959955c43e2af2fbd03418e82a2bd5464604ec9a62147e37aceb420b"
  head "https://github.com/bagder/c-ares.git"

  bottle do
    cellar :any
    sha256 "68d6374d5665448f947c8cfb2090171c0c865e239a786139f108979138d03a68" => :el_capitan
    sha1 "aa711a345bac4780f2e7737c212c1fb5f7862de8" => :yosemite
    sha1 "c6851c662552524fa92e341869a23ea72dbc4375" => :mavericks
    sha1 "27494a19ac612daedeb55356e911328771f94b19" => :mountain_lion
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
