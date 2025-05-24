class Pcre < Formula
  desc "Perl compatible regular expressions library"
  homepage "https://www.pcre.org/"
  url "https://downloads.sourceforge.net/project/pcre/pcre/8.45/pcre-8.45.tar.bz2"
  sha256 "4dae6fdcd2bb0bb6c37b5f97c33c2be954da743985369cddac3546e3218bffb8"

  bottle do
    sha256 "e89c54115a9b58735dd9548c0974a657e9bbce263642aa43264573385e360960" => :tiger_altivec
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
