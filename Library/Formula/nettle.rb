class Nettle < Formula
  desc "Low-level cryptographic library"
  homepage "https://www.lysator.liu.se/~nisse/nettle/"
  url "https://ftp.gnu.org/gnu/nettle/nettle-3.9.1.tar.gz"
  mirror "https://ftpmirror.gnu.org/gnu/nettle/nettle-3.9.1.tar.gz"
  sha256 "ccfeff981b0ca71bbd6fbcb054f407c60ffb644389a5be80d6716d5b550c6ce3"
  revision 1

  bottle do
    sha256 "1272ad455c11d0fe71d726782b94f1ba2dd4dc624eb420bf05118465d9abdc27" => :tiger_altivec
  end

  depends_on "gmp"
  depends_on "openssl3"

  def install
    # Tests fail when running test suite
    ENV.no_optimization
    # see https://github.com/mistydemeo/tigerbrew/issues/89
    ENV.enable_warnings if ENV.compiler == :gcc_4_0

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-shared"
    system "make"
    system "make", "install"
    # C++ tests which depend on GMP fail to build with GCC 4.0.1
    system "make", "check"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <nettle/sha1.h>
      #include <stdio.h>

      int main()
      {
        struct sha1_ctx ctx;
        uint8_t digest[SHA1_DIGEST_SIZE];
        unsigned i;

        sha1_init(&ctx);
        sha1_update(&ctx, 4, "test");
        sha1_digest(&ctx, SHA1_DIGEST_SIZE, digest);

        printf("SHA1(test)=");

        for (i = 0; i<SHA1_DIGEST_SIZE; i++)
          printf("%02x", digest[i]);

        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-lnettle", "-o", "test", "-L#{lib}"
    system "./test"
  end
end
