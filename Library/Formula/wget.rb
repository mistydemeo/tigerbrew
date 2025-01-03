# NOTE: Configure will fail if using awk 20110810 from dupes.
# Upstream issue: https://savannah.gnu.org/bugs/index.php?37063

class Wget < Formula
  desc "Internet file retriever"
  homepage "https://www.gnu.org/software/wget/"
  url "https://ftpmirror.gnu.org/wget/wget-1.24.5.tar.gz"
  mirror "https://ftp.gnu.org/gnu/wget/wget-1.24.5.tar.gz"
  sha256 "fa2dc35bab5184ecbc46a9ef83def2aaaa3f4c9f3c97d4bd19dcb07d4da637de"

  head do
    url "git://git.savannah.gnu.org/wget.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext"
  end

  bottle do
  end

  deprecated_option "enable-debug" => "with-debug"

  option "with-debug", "Build with debug support"

  depends_on "pkg-config" => :build
  depends_on "openssl3" => :recommended
  depends_on "libressl" => :optional
  depends_on "libidn2" => :recommended
  depends_on "pcre2" => :recommended
  depends_on "libunistring"
  depends_on "zlib"

  def install
  ENV.append "CFLAGS", "-std=gnu99"
    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --with-ssl=openssl
      --disable-pcre
    ]

    if build.with? "libressl"
      args << "--with-libssl-prefix=#{Formula["libressl"].opt_prefix}"
    else
      args << "--with-libssl-prefix=#{Formula["openssl3"].opt_prefix}"
    end

    args << "--disable-debug" if build.without? "debug"
    args << "--disable-iri" if build.without? "libidn2"
    args << "--disable-pcre2" if build.without? "pcre2"

    system "./bootstrap" if build.head?
    system "./configure", *args
    system "make", "install"
  end

  test do
    system bin/"wget", "-O", "/dev/null", "https://example.com"
  end
end
