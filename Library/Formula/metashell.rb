class Metashell < Formula
  desc "Metaprogramming shell for C++ templates"
  homepage "https://github.com/sabel83/metashell"
  url "https://github.com/sabel83/metashell/archive/v2.1.0.tar.gz"
  sha256 "64d3680a536a254de8556a9792c5d35e6709f2f347d7187614271123d87246ee"


  depends_on "cmake" => :build

  needs :cxx11

  # This patch is required because Mountain Lion uses an old compiler which breaks
  # compiling some Templight code. The patch comments out unused parts of Templight,
  # so patched version is functionally equivalent. This error should be fixed in
  # the next release of Metashell.
  # https://github.com/sabel83/metashell/issues/28
  patch :DATA if MacOS.version == :mountain_lion

  def install
    ENV.cxx11

    # Build internal Clang
    mkdir "3rd/templight/build" do
      system "cmake", "../llvm", "-DLIBCLANG_BUILD_STATIC=ON", *std_cmake_args
      system "make", "clang"
      system "make", "libclang"
      system "make", "libclang_static"
      system "make", "templight"
    end

    system "tools/clang_default_path --gcc=clang > lib/core/extra_sysinclude.hpp"

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.hpp").write <<-EOS.undent
      template <class T> struct add_const { using type = const T; };
      add_const<int>::type
    EOS
    assert_match /const int/, shell_output("cat #{testpath}/test.hpp | #{bin}/metashell -H")
  end
end

__END__
diff --git a/3rd/templight/llvm/tools/clang/tools/templight/TemplightDebugger.cpp b/3rd/templight/llvm/tools/clang/tools/templight/TemplightDebugger.cpp
index 7a5a2d3..c60d7de 100644
--- a/3rd/templight/llvm/tools/clang/tools/templight/TemplightDebugger.cpp
+++ b/3rd/templight/llvm/tools/clang/tools/templight/TemplightDebugger.cpp
@@ -672,6 +672,7 @@ public:
   };

   void processInputs() {
+#if 0
     std::string user_in;
     while(true) {
       llvm::outs() << "(tdb) ";
@@ -958,6 +959,7 @@ public:
       }

     };
+#endif
   };

   void printRawEntry(const TemplateDebuggerEntry &Entry) {
