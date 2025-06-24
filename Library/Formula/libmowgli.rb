class Libmowgli < Formula
  desc "Core framework for Atheme applications"
  homepage "http://www.atheme.org/project/mowgli"
  url "https://github.com/atheme/libmowgli-2/archive/libmowgli-2.0.0.tar.gz"
  sha256 "fd48e74f1f706b436e0f25c3d3d63753e9c066ef88e662cd34303ccd3b780798"
  revision 1

  head "https://github.com/atheme/libmowgli-2.git"


  depends_on "openssl"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--with-openssl=#{Formula["openssl"].opt_prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <mowgli.h>

      int main(int argc, char *argv[]) {
        char buf[65535];
        mowgli_random_t *r = mowgli_random_create();
        mowgli_formatter_format(buf, 65535, "%1! %2 %3 %4.",\
                    "sdpb", "Hello World", mowgli_random_int(r),\
                    0xDEADBEEF, TRUE);
        puts(buf);
        mowgli_object_unref(r);
        return EXIT_SUCCESS;
      }
    EOS
    system ENV.cc, "-I#{include}/libmowgli-2", "-o", "test", "test.c", "-lmowgli-2"
    system "./test"
  end
end
