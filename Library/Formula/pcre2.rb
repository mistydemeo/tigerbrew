class Pcre2 < Formula
  desc "Perl compatible regular expressions library with a new API"
  homepage "https://www.pcre.org/"
  url "https://ftp.pcre.org/pub/pcre/pcre2-10.30.tar.bz2"
  sha256 "90bd41c605d30e3745771eb81928d779f158081a51b2f314bbcc1f73de5773db"

  head "svn://vcs.exim.org/pcre2/code/trunk"

  bottle do
    cellar :any
    sha256 "bd0d09c9849ec4ce62bff6bf422cf8c42dfa7d39e684c0d7e7d3d176a749ab76" => :tiger_g3
    sha256 "032c6cc3f59a97be735e385714da097201d03afb5ecc1ee943d0f5ebf8f06d52" => :tiger_altivec
    sha256 "23e8ed207c87f4a77e01b49d1972de94795e398ab00e4fe1d2260f1c905306f7" => :tiger_g5
    sha256 "e4f42029c07e1ddbc7b0efe938b911f66b5fbb8404a18542ee4bd0156274b7cb" => :leopard_g4e
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-pcre2-16",
                          "--enable-pcre2-32",
                          "--enable-pcre2grep-libz",
                          "--enable-pcre2grep-libbz2",
                          "--enable-jit"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/pcre2grep", "regular expression", prefix/"README"
  end
end
