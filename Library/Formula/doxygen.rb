class Doxygen < Formula
  desc "Generate documentation for several programming languages"
  homepage "http://www.doxygen.org/"
  url "http://ftp.stack.nl/pub/users/dimitri/doxygen-1.8.10.src.tar.gz"
  mirror "https://downloads.sourceforge.net/project/doxygen/rel-1.8.10/doxygen-1.8.10.src.tar.gz"
  sha256 "cedf78f6d213226464784ecb999b54515c97eab8a2f9b82514292f837cf88b93"
  head "https://github.com/doxygen/doxygen.git"


  option "with-graphviz", "Build with dot command support from Graphviz."
  option "with-doxywizard", "Build GUI frontend with qt support."
  option "with-libclang", "Build with libclang support."

  deprecated_option "with-dot" => "with-graphviz"

  depends_on :ld64
  depends_on "flex" if MacOS.version < :leopard
  depends_on "cmake" => :build
  depends_on "graphviz" => :optional
  depends_on "qt" if build.with? "doxywizard"
  depends_on "llvm" => "with-clang" if build.with? "libclang"

  # /Developer/SDKs/MacOSX10.4u.sdk/usr/include/stdarg.h:4:25: error: stdarg.h: No such file or directory
  fails_with :gcc if MacOS.version == :tiger

  def install
    # This flag was introduced after GCC 4.2.
    # This is necessary on Tiger, since we don't have superenv yet.
    if [:gcc, :gcc_4_0].include? ENV.compiler
      inreplace "CMakeLists.txt", "-Wno-deprecated-register", ""
    end

    args = std_cmake_args
    args << "-Dbuild_wizard=ON" if build.with? "doxywizard"
    args << "-Duse_libclang=ON -DLLVM_CONFIG=#{Formula["llvm"].opt_bin}/llvm-config" if build.with? "libclang"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
    end
    bin.install Dir["build/bin/*"]
    man1.install Dir["doc/*.1"]
  end

  test do
    system "#{bin}/doxygen", "-g"
    system "#{bin}/doxygen", "Doxyfile"
  end
end
