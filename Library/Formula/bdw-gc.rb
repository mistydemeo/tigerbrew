class BdwGc < Formula
  desc "Garbage collector for C and C++"
  homepage "http://www.hboehm.info/gc/"
  url "https://www.hboehm.info/gc/gc_source/gc-7.6.12.tar.gz"
  sha256 "6cafac0d9365c2f8604f930aabd471145ac46ab6f771e835e57995964e845082"
  revision 1

  bottle do
    sha256 "752d520bbcb5b22bf16a6480b4471dad47f58a83eb7444f018999e482511b32f" => :tiger_altivec
  end

  head do
    url "https://github.com/ivmai/bdwgc.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool"  => :build
  end

  option :universal
  option "with-tests", "Build and run the test suite"

  depends_on "pkg-config" => :build
  depends_on "libatomic_ops"

  def install
    ENV.universal_binary if build.universal?

    system "./autogen.sh" if build.head?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-cplusplus"
    system "make"
    system "make", "check" if build.with?("tests") || build.bottle?
    system "make", "install"
  end
end
