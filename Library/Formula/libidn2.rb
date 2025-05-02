class Libidn2 < Formula
  desc "International domain name library (IDNA2008, Punycode and TR46)"
  homepage "https://www.gnu.org/software/libidn/#libidn2"
  url "https://ftp.gnu.org/gnu/libidn/libidn2-2.3.8.tar.gz"
  mirror "https://ftpmirror.gnu.org/libidn/libidn2-2.3.8.tar.gz"
  mirror "http://ftp.gnu.org/gnu/libidn/libidn2-2.3.8.tar.gz"
  sha256 "f557911bf6171621e1f72ff35f5b1825bb35b52ed45325dcdee931e5d3c0787a"
  license any_of: ["GPL-2.0-or-later", "LGPL-3.0-or-later"]

  head do
    url "https://gitlab.com/libidn/libidn2.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gengetopt" => :build
    depends_on "gettext" => :build
    depends_on "help2man" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "libunistring"
  depends_on "gettext"

  def install
    args = ["--disable-silent-rules", "--with-packager=Homebrew", "--prefix=#{prefix}"]
    args << "--with-libintl-prefix=#{Formula["gettext"].opt_prefix}"

    system "./bootstrap", "--skip-po" if build.head?
    system "./configure", *args
    system "make", "install"
  end

  test do
    ENV.delete("LC_CTYPE")
    ENV["CHARSET"] = "UTF-8"
    output = shell_output("#{bin}/idn2 räksmörgås.se")
    assert_equal "xn--rksmrgs-5wao1o.se", output.chomp
    output = shell_output("#{bin}/idn2 blåbærgrød.no")
    assert_equal "xn--blbrgrd-fxak7p.no", output.chomp
  end
end
