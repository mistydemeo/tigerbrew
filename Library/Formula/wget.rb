# NOTE: Configure will fail if using awk 20110810 from dupes.
# Upstream issue: https://savannah.gnu.org/bugs/index.php?37063

class Wget < Formula
  desc "Internet file retriever"
  homepage "https://www.gnu.org/software/wget/"
  url "https://ftpmirror.gnu.org/wget/wget-1.25.0.tar.gz"
  mirror "https://ftp.gnu.org/gnu/wget/wget-1.25.0.tar.gz"
  sha256 "766e48423e79359ea31e41db9e5c289675947a7fcf2efdcedb726ac9d0da3784"

  head do
    url "git://git.savannah.gnu.org/wget.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  bottle do
    sha256 "a6cc31e4f05842b053fce81c677f41a25e5b56f6b04c67267f1d25b7354dec89" => :tiger_altivec
    sha256 "1ec759b79ccd72ea8969999ead9a68d2de64d58464ad4c540d471568db14bdf1" => :tiger_g3
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
  depends_on "gettext"
  depends_on "libiconv"
  depends_on "libpsl"

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
