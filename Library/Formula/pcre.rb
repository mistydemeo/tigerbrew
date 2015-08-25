class Pcre < Formula
  desc "Perl compatible regular expressions library"
  homepage "http://www.pcre.org/"
  url "https://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.37.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/downloads.sourceforge.net/p/pc/pcre/pcre/8.37/pcre-8.37.tar.bz2"
  sha256 "51679ea8006ce31379fb0860e46dd86665d864b5020fc9cd19e71260eef4789d"

  head do
    url "svn://vcs.exim.org/pcre/code/trunk"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  bottle do
    cellar :any
    sha256 "e3d59e4d7c6bce68f7db7c62e13f9fec54f5fb905ce242e654975503e7dbf9e8" => :tiger_altivec
    sha256 "b7a492a51680eb558534e4ae14ff5e9ac797a53cff40adb30599b783922ee475" => :leopard_g3
    sha256 "b12c914a86261483456550a93e4abd1baba1ecdcf342f7c2b1e5f545bf7fe1ab" => :leopard_altivec
  end

  option :universal

  # See https://github.com/mistydemeo/tigerbrew/issues/93
  fails_with :gcc do
    build 5553
    cause "One test failure on G4"
  end

  fails_with :llvm do
    build 2326
    cause "Bus error in ld on SL 10.6.4"
  end

  def install
    ENV.universal_binary if build.universal?

    args = [ "--disable-dependency-tracking",
              "--prefix=#{prefix}",
              "--enable-utf8",
              "--enable-pcre8",
              "--enable-pcre16",
              "--enable-pcre32",
              "--enable-unicode-properties",
              "--enable-pcregrep-libz",
              "--enable-pcregrep-libbz2" ]

    # JIT fails tests very badly on PPC right now
    args << "--enable-jit" unless Hardware::CPU.type == :ppc

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make"
    ENV.deparallelize
    system "make", "test"
    system "make", "install"
  end

  test do
    system "#{bin}/pcregrep", "regular expression", "#{prefix}/README"
  end
end
