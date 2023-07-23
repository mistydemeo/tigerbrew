class Bzip2 < Formula
  desc "Freely available high-quality data compressor"
  homepage "https://sourceware.org/bzip2/"
  url "https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz"
  sha256 "ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269"
  license "bzip2-1.0.6"

  keg_only :provided_by_osx

  def install
    inreplace "Makefile", "$(PREFIX)/man", "$(PREFIX)/share/man"

    system "make", "clean"
    system "make"
    system "make", "install", "PREFIX=#{prefix}"

    # Install shared libraries
    system "make", "-f", "Makefile-libbz2_so", "clean"
    system "make", "-f", "Makefile-libbz2_so"

    lib.install "libbz2.1.0.8.dylib", "libbz2.1.0.dylib"
    lib.install_symlink "libbz2.#{version}.dylib" => "libbz2.dylib"
    cp "bzip2-shared", "#{bin}/bzip2"
    cp "bzip2-shared", "#{bin}/bunzip2"
    cp "bzip2-shared", "#{bin}/bzcat"

    # Create pkgconfig file based on 1.1.x repository.
    # https://gitlab.com/bzip2/bzip2/-/blob/master/bzip2.pc.in
    (lib/"pkgconfig/bzip2.pc").write <<~EOS
      prefix=#{opt_prefix}
      exec_prefix=${prefix}
      bindir=${exec_prefix}/bin
      libdir=${exec_prefix}/lib
      includedir=${prefix}/include

      Name: bzip2
      Description: Lossless, block-sorting data compression
      Version: #{version}
      Libs: -L${libdir} -lbz2
      Cflags: -I${includedir}
    EOS
  end

  test do
    testfilepath = testpath + "sample_in.txt"
    zipfilepath = testpath + "sample_in.txt.bz2"

    testfilepath.write "TEST CONTENT"

    system "#{bin}/bzip2", testfilepath
    system "#{bin}/bunzip2", zipfilepath

    assert_equal "TEST CONTENT", testfilepath.read
  end

  # Need to generate a library
  patch :p0, :DATA
end
__END__
--- Makefile-libbz2_so.orig	2019-07-13 18:50:05.000000000 +0100
+++ Makefile-libbz2_so	2023-05-21 02:36:45.000000000 +0100
@@ -35,13 +35,13 @@
       bzlib.o
 
 all: $(OBJS)
-	$(CC) -shared -Wl,-soname -Wl,libbz2.so.1.0 -o libbz2.so.1.0.8 $(OBJS)
-	$(CC) $(CFLAGS) -o bzip2-shared bzip2.c libbz2.so.1.0.8
-	rm -f libbz2.so.1.0
-	ln -s libbz2.so.1.0.8 libbz2.so.1.0
+	$(CC) -dynamiclib -o libbz2.1.0.8.dylib $(OBJS)
+	$(CC) $(CFLAGS) -o bzip2-shared bzip2.c libbz2.1.0.8.dylib
+	rm -f libbz2.1.0.dylib
+	ln -s libbz2.1.0.8.dylib libbz2.1.0.dylib
 
 clean: 
-	rm -f $(OBJS) bzip2.o libbz2.so.1.0.8 libbz2.so.1.0 bzip2-shared
+	rm -f $(OBJS) bzip2.o libbz2.1.0.8.dylib libbz2.1.0.dylib bzip2-shared
 
 blocksort.o: blocksort.c
 	$(CC) $(CFLAGS) -c blocksort.c
