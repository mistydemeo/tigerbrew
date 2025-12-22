class Confuse < Formula
  desc "Configuration file parser library written in C"
  homepage "https://github.com/libconfuse/libconfuse"
  url "https://github.com/libconfuse/libconfuse/releases/download/v3.0/confuse-3.0.tar.xz"
  sha256 "bb75174e02aa8b44fa1a872a47beeea1f5fe715ab669694c97803eb6127cc861"
  license "ISC"

  bottle do
    cellar :any
    sha256 "cafa47896501ef96ea47c89128602f7f2c3fda786ff19fb52e0b77e2330ddf00" => :tiger_altivec
    sha256 "2455f6d628b6939560514f405414d01d0562e9ab020469fc4918c065592a1e92" => :tiger_g3
  end

  option "with-tests", "Build and run the test suite"

  depends_on "pkg-config" => :build

  def install
    # Need unsetenv(3) to return int, not void
    ENV.append_to_cflags "-D__DARWIN_UNIX03" if MacOS.version == :tiger
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "check" if build.with?("tests") || build.bottle?
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <confuse.h>
      #include <stdio.h>

      cfg_opt_t opts[] =
      {
        CFG_STR("hello", NULL, CFGF_NONE),
        CFG_END()
      };

      int main(void)
      {
        cfg_t *cfg = cfg_init(opts, CFGF_NONE);
        if (cfg_parse_buf(cfg, "hello=world") == CFG_SUCCESS)
          printf("%s\\n", cfg_getstr(cfg, "hello"));
        cfg_free(cfg);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lconfuse", "-o", "test"
    assert_match "world", shell_output("./test")
  end
end
