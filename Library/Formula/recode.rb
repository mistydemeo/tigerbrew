class Recode < Formula
  desc "Convert character set (charsets)"
  homepage "https://web.archive.org/web/20140620121336/http://recode.progiciels-bpi.ca/index.html"
  url "https://github.com/rrthomas/recode/releases/download/v3.7.14/recode-3.7.14.tar.gz"
  sha256 "786aafd544851a2b13b0a377eac1500f820ce62615ccc2e630b501e7743b9f33"
  version "3.7.14"

  depends_on "gettext"
  depends_on "libiconv"
  depends_on "libtool" => :build

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
