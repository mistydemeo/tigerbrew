class Recode < Formula
  desc "Convert character set (charsets)"
  homepage "https://web.archive.org/web/20140620121336/http://recode.progiciels-bpi.ca/index.html"
  url "https://github.com/rrthomas/recode/releases/download/v3.7.14/recode-3.7.14.tar.gz"
  sha256 "786aafd544851a2b13b0a377eac1500f820ce62615ccc2e630b501e7743b9f33"
  version "3.7.14"

  bottle do
    sha256 "b2c366054028f5cc6fc911747e227f2b4dd05230c6a1818037f84fa0d66d300e" => :tiger_altivec
  end

  depends_on "gettext"
  depends_on "libiconv"
  depends_on "libtool" => :build

  # Fails with 4.2 but not 4.0 on Tiger
  # https://github.com/mistydemeo/tigerbrew/pull/1218
  fails_with :gcc if MacOS.version < :leopard

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--infodir=#{info}",
                          "--with-libiconv-prefix=#{Formula["libiconv"].opt_prefix}",
                          "--with-libintl-prefix=#{Formula["gettext"].opt_prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end
end
