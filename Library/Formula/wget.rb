# NOTE: Configure will fail if using awk 20110810 from dupes.
# Upstream issue: https://savannah.gnu.org/bugs/index.php?37063

class Wget < Formula
  desc "Internet file retriever"
  homepage "https://www.gnu.org/software/wget/"
  url "http://ftpmirror.gnu.org/wget/wget-1.16.3.tar.xz"
  mirror "https://ftp.gnu.org/gnu/wget/wget-1.16.3.tar.xz"
  sha256 "67f7b7b0f5c14db633e3b18f53172786c001e153d545cfc85d82759c5c2ffb37"

  bottle do
    sha256 "fb5c9be7a3a077cf5f5f8feb5114ce9c8bd8294c5601a6d85b9d82e4e24dc42d" => :tiger_altivec
    sha256 "cdcfb345558d8373ee75de0ef538d60a41374847304475c430f05bac356cf7e5" => :leopard_g3
    sha256 "64e80dbf71fe2b1741e054c3942dce0201bb0149eb938169bc2524523cadff04" => :leopard_altivec
  end

  head do
    url "git://git.savannah.gnu.org/wget.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "xz" => :build
    depends_on "gettext"
  end

  deprecated_option "enable-iri" => "with-iri"
  deprecated_option "enable-debug" => "with-debug"

  option "with-iri", "Enable iri support"
  option "with-debug", "Build with debug support"

  depends_on "openssl" => :recommended
  depends_on "libressl" => :optional
  depends_on "libidn" if build.with? "iri"
  depends_on "pcre" => :optional

  def install
    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --with-ssl=openssl
    ]

    if build.with? "libressl"
      args << "--with-libssl-prefix=#{Formula["libressl"].opt_prefix}"
    else
      args << "--with-libssl-prefix=#{Formula["openssl"].opt_prefix}"
    end

    args << "--disable-debug" if build.without? "debug"
    args << "--disable-iri" if build.without? "iri"
    args << "--disable-pcre" if build.without? "pcre"

    system "./bootstrap" if build.head?
    system "./configure", *args
    system "make", "install"
  end

  test do
    system bin/"wget", "-O", "-", "https://google.com"
  end
end
