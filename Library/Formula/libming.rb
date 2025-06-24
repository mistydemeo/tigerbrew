class Libming < Formula
  desc "C library for generating Macromedia Flash files"
  homepage "http://www.libming.org"
  url "https://downloads.sourceforge.net/project/ming/Releases/ming-0.4.4.tar.bz2"
  sha256 "40e09d781741ac961338ed8dec7ba2ed06217de9da44dd67af6b881b95d2af7e"
  revision 1


  option "perl", "Build the perl extension"
  option "php", "Build the php extension"

  depends_on "libpng"
  depends_on "freetype"
  depends_on :python => :optional
  depends_on "giflib" => :optional

  # Helps us find libgif.dylib, not libungif.dylib which is retired.
  patch :DATA

  def install
    # TODO: Libming also includes scripting front-ends for Perl, Python, TCL
    # and PHP. These are disabled by default. Figure out what it would take to
    # enable them.
    # - python works if we tell it to use our giflib not ungif.
    # - perl works without any change
    # - php builds, but tries to install to /usr/lib/php/extensions
    # - tcl does not work, might need an older tcl, missing symbols.
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
    ]
    args << "--enable-python" if build.with? "python"
    args << "--enable-perl" if build.with? "perl"
    args << "--enable-php" if build.with? "php"

    system "./configure", *args
    system "make"

    # Won't install in parallel for some reason.
    ENV.deparallelize
    system "make", "install"
  end
end

__END__
--- a/py_ext/setup.py.in	2011-10-25 23:33:18.000000000 -0700
+++ b/py_ext/setup.py.in	2012-09-04 13:39:52.000000000 -0700
@@ -19,7 +19,7 @@
 	mylibs.append('png')
 
 if "@GIFLIB@":
-	mylibs.append("ungif")
+	mylibs.append("gif")
 
 
 setup(name = "mingc", version = "@MING_VERSION@",
