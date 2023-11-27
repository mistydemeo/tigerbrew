class Libidn2 < Formula
  desc "International domain name library (IDNA2008, Punycode and TR46)"
  homepage "https://www.gnu.org/software/libidn/#libidn2"
  url "https://ftp.gnu.org/gnu/libidn/libidn2-2.3.4.tar.gz"
  mirror "https://ftpmirror.gnu.org/libidn/libidn2-2.3.4.tar.gz"
  mirror "http://ftp.gnu.org/gnu/libidn/libidn2-2.3.4.tar.gz"
  sha256 "93caba72b4e051d1f8d4f5a076ab63c99b77faee019b72b9783b267986dbb45f"
  license any_of: ["GPL-2.0-or-later", "LGPL-3.0-or-later"]

  bottle do
    sha256 "443cafce41e04212d9d44d283ed1efed6df3955f86346543ebf761cd18153e23" => :tiger_altivec
  end

  head do
    url "https://gitlab.com/libidn/libidn2.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gengetopt" => :build
    depends_on "gettext" => :build
    depends_on "help2man" => :build
    depends_on "libtool" => :build
    depends_on "ronn" => :build

    # uses_from_macos "gperf" => :build

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
