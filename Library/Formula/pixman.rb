class Pixman < Formula
  desc "Low-level library for pixel manipulation"
  homepage "http://cairographics.org/"
  url "https://www.cairographics.org/releases/pixman-0.42.2.tar.gz"
  sha256 "ea1480efada2fd948bc75366f7c349e1c96d3297d09a3fe62626e38e234a625e"

  bottle do
    sha256 "dd997d0cc6e60b1eae7e5a88dd23d797d8c8ce75c1c853129c58b153e4102874" => :tiger_altivec
  end

  option :universal

  depends_on "pkg-config" => :build

  keg_only :provided_pre_mountain_lion

  fails_with :llvm do
    build 2336
    cause <<-EOS.undent
      Building with llvm-gcc causes PDF rendering issues in Cairo.
      https://trac.macports.org/ticket/30370
      See Homebrew issues #6631, #7140, #7463, #7523.
      EOS
  end

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--disable-gtk",
                          "--disable-mmx", # MMX assembler fails with Xcode 7
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <pixman.h>

      int main(int argc, char *argv[])
      {
        pixman_color_t white = { 0xffff, 0xffff, 0xffff, 0xffff };
        pixman_image_t *image = pixman_image_create_solid_fill(&white);
        pixman_image_unref(image);
        return 0;
      }
    EOS
    flags = (ENV.cflags || "").split + (ENV.cppflags || "").split + (ENV.ldflags || "").split
    flags += %W[
      -I#{include}/pixman-1
      -L#{lib}
      -lpixman-1
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end

  # Older versions of GCC have issue with scaled_nearest_scanline_vmx_8888_8888_OVER()
  # https://lists.freedesktop.org/archives/pixman/2016-April/004577.html
  patch :p0, :DATA

end
__END__
--- pixman/pixman-vmx.c.orig	2023-05-26 02:25:41.000000000 +0100
+++ pixman/pixman-vmx.c	2023-05-26 02:27:10.000000000 +0100
@@ -2933,10 +2933,7 @@
 	while (vx >= 0)
 	    vx -= src_width_fixed;
 
-	tmp[0] = tmp1;
-	tmp[1] = tmp2;
-	tmp[2] = tmp3;
-	tmp[3] = tmp4;
+	tmp = (vector unsigned int){tmp1, tmp2, tmp3, tmp4};
 
 	vsrc = combine4 ((const uint32_t *) &tmp, pm);
 
