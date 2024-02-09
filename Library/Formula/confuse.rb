class Confuse < Formula
  desc "Configuration file parser library written in C"
  homepage "https://github.com/libconfuse/libconfuse"
  url "https://github.com/libconfuse/libconfuse/releases/download/v3.3/confuse-3.3.tar.xz"
  sha256 "1dd50a0320e135a55025b23fcdbb3f0a81913b6d0b0a9df8cc2fdf3b3dc67010"
  license "ISC"

  bottle do
  end

  # fmemopen() implementation for systems which lack it is broken, sidestep the issue
  # by not using it for the test case.
  # https://github.com/libconfuse/libconfuse/issues/147
  patch :p0, :DATA

  depends_on "pkg-config" => :build

  def install
    # Need unsetenv(3) to return int, not void
    ENV.append_to_cflags "-D__DARWIN_UNIX03" if MacOS.version == :tiger
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "check"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    If you are installing libconfuse with the intention of
    using it for writing a application or a dependency for
    something other than libftdi, you should avoid using
    the fmemopen implementation supplied with libconfuse
    along with its functions which perform operations on
    a file pointer as things will generally not work.
    See tests/empty_string.c in the unpatched source code
    as an example which is broken.
    EOS
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
__END__
--- tests/empty_string.c.orig	2024-02-07 00:08:37.000000000 +0000
+++ tests/empty_string.c	2024-02-09 00:14:12.000000000 +0000
@@ -23,7 +23,7 @@
 	cfg = cfg_init(opts, 0);
 	fail_unless(cfg_parse_buf(cfg, "string = ''") == CFG_SUCCESS);
 	fail_unless(strcmp(cfg_getstr(cfg, "string"), "") == 0);
-	f = fmemopen(buf, sizeof(buf), "w+");
+	f = tmpfile();
 	fail_unless(f != NULL);
 	cfg_print(cfg, f);
 	cfg_free(cfg);
