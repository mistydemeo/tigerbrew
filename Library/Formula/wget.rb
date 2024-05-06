# NOTE: Configure will fail if using awk 20110810 from dupes.
# Upstream issue: https://savannah.gnu.org/bugs/index.php?37063

class Wget < Formula
  desc "Internet file retriever"
  homepage "https://www.gnu.org/software/wget/"
  url "https://ftpmirror.gnu.org/wget/wget-1.21.3.tar.gz"
  mirror "https://ftp.gnu.org/gnu/wget/wget-1.21.3.tar.gz"
  sha256 "5726bb8bc5ca0f6dc7110f6416e4bb7019e2d2ff5bf93d1ca2ffcc6656f220e5"
  revision 1

  head do
    url "git://git.savannah.gnu.org/wget.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext"
  end

  bottle do
    sha256 "81581a3befe8af2552a4f6b3a574b712ae9fb0f85b2d1bbe1f1de2e96d4d1a9f" => :tiger_altivec
  end

  deprecated_option "enable-iri" => "with-iri"
  deprecated_option "enable-debug" => "with-debug"

  option "with-iri", "Enable iri support"
  option "with-debug", "Build with debug support"

  depends_on "openssl3" => :recommended
  depends_on "libressl" => :optional
  depends_on "libidn" if build.with? "iri"
  depends_on "pcre2" => :optional
  depends_on "zlib"

  def install
  ENV.append "CFLAGS", "-std=gnu99"
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
    system bin/"wget", "-O", "-", "https://github.com"
  end
end
