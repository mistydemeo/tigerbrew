class Liblinear < Formula
  desc "Library for large linear classification"
  homepage "https://www.csie.ntu.edu.tw/~cjlin/liblinear/"
  url "https://www.csie.ntu.edu.tw/~cjlin/liblinear/liblinear-2.47.tar.gz"
  sha256 "99ce98ca3ce7cfb31f2544c42f23ba5bc6c226e536f95d6cd21fe012f94c65e0"

  head "https://github.com/cjlin1/liblinear.git"

  bottle do
    cellar :any
    sha256 "fbbe47f5c260e033914950c59a5efc00f8f990e97f2e6fe4b4cddd50b355a85c" => :tiger_altivec
  end

  # Fix sonames
  patch :p0, :DATA

  def install
    system "make", "all"
    bin.install "predict", "train"
    lib.install "liblinear.5.dylib"
    lib.install_symlink "liblinear.dylib" => "liblinear.5.dylib"
    include.install "linear.h"
  end

  test do
    (testpath/"train_classification.txt").write <<-EOS.undent
    +1 201:1.2 3148:1.8 3983:1 4882:1
    -1 874:0.3 3652:1.1 3963:1 6179:1
    +1 1168:1.2 3318:1.2 3938:1.8 4481:1
    +1 350:1 3082:1.5 3965:1 6122:0.2
    -1 99:1 3057:1 3957:1 5838:0.3
    EOS

    system "#{bin}/train", "train_classification.txt"
  end
end
__END__
--- Makefile.orig	2023-07-09 13:45:51.000000000 +0100
+++ Makefile	2024-01-29 20:39:16.000000000 +0000
@@ -5,16 +5,20 @@
 #LIBS = -lblas
 SHVER = 5
 OS = $(shell uname)
+PREFIX ?= /usr/local
+
 ifeq ($(OS),Darwin)
-	SHARED_LIB_FLAG = -dynamiclib -Wl,-install_name,liblinear.so.$(SHVER)
+	LIBEXT = .$(SHVER).dylib
+	SHARED_LIB_FLAG = -dynamiclib -install_name $(PREFIX)/lib/liblinear$(LIBEXT)
 else
-	SHARED_LIB_FLAG = -shared -Wl,-soname,liblinear.so.$(SHVER)
+	LIBEXT = .so.$(SHVER)
+	SHARED_LIB_FLAG = -shared -Wl,-soname,liblinear$(LIBEXT)
 endif
 
-all: train predict
+all: train predict lib
 
 lib: linear.o newton.o blas/blas.a
-	$(CXX) $(SHARED_LIB_FLAG) linear.o newton.o blas/blas.a -o liblinear.so.$(SHVER)
+	$(CXX) $(SHARED_LIB_FLAG) linear.o newton.o blas/blas.a -o liblinear$(LIBEXT)
 
 train: newton.o linear.o train.c blas/blas.a
 	$(CXX) $(CFLAGS) -o train train.c newton.o linear.o $(LIBS)
@@ -34,4 +38,4 @@
 clean:
 	make -C blas clean
 	make -C matlab clean
-	rm -f *~ newton.o linear.o train predict liblinear.so.$(SHVER)
+	rm -f *~ newton.o linear.o train predict liblinear.*
