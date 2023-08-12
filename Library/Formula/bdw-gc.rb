class BdwGc < Formula
  desc "Garbage collector for C and C++"
  homepage "http://www.hboehm.info/gc/"
  url "http://www.hboehm.info/gc/gc_source/gc-7.4.2.tar.gz"
  sha256 "63320ad7c45460e4a40e03f5aa4c6893783f21a16416c3282b994f933312afa2"

  bottle do
    sha256 "6eb8d50bfdca0a3813bad99d17acb9adbd4f884b4022d8031ec2acb11cd5b565" => :tiger_altivec
  end

  head do
    url "https://github.com/ivmai/bdwgc.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool"  => :build
  end

  option :universal

  depends_on "pkg-config" => :build
  depends_on "libatomic_ops" => :build

  def install
    ENV.universal_binary if build.universal?

    system "./autogen.sh" if build.head?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-cplusplus"
    system "make"
    system "make", "check"
    system "make", "install"
  end
end
