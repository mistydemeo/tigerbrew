class Hercules < Formula
  desc "System/370, ESA/390 and z/Architecture Emulator"
  homepage "http://www.hercules-390.eu/"
  url "http://downloads.hercules-390.eu/hercules-3.13.tar.gz"
  sha256 "890c57c558d58708e55828ae299245bd2763318acf53e456a48aac883ecfe67d"

  skip_clean :la

  head do
    url "https://github.com/hercules-390/hyperion.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "bzip2"
  depends_on "zlib"

  # error: thread-local storage not supported for this target
  fails_with :gcc_4_0
  fails_with :gcc
  fails_with :llvm

  def install
    # We build with -O3 instead
    ENV.no_optimization

    system "./autogen.sh" if build.head?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-optimization=yes"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test00.ctl").write <<~EOS
      TEST00 3390 10
      TEST.PDS EMPTY CYL 1 0 5 PO FB 80 6080
    EOS

    system bin/"dasdload", "test00.ctl", "test00.ckd"
  end
end
