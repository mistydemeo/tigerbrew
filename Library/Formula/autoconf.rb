class Autoconf < Formula
  desc "Automatic configure script builder"
  homepage "https://www.gnu.org/software/autoconf"
  url "https://ftpmirror.gnu.org/autoconf/autoconf-2.73.tar.xz"
  mirror "https://ftp.gnu.org/gnu/autoconf/autoconf-2.73.tar.xz"
  sha256 "9fd672b1c8425fac2fa67fa0477b990987268b90ff36d5f016dae57be0d6b52e"

  # There are references to prefix in generated files,
  # can't use any_skip_relocation
  bottle do
  end

  # Bundled m4 is too old, also need new automake if running test suite.
  depends_on "m4"

  keg_only :provided_until_xcode43

  def install
    ENV["PERL"] = "/usr/bin/perl"

    # force autoreconf to look for and use our glibtoolize
    inreplace "bin/autoreconf.in", "libtoolize", "glibtoolize"
    # also touch the man page so that it isn't rebuilt
    inreplace "man/autoreconf.1", "libtoolize", "glibtoolize"

    system "./configure", "--prefix=#{prefix}",
           "--with-lispdir=#{share}/emacs/site-lisp/autoconf"
    system "make", "install"

    rm_f info/"standards.info"
  end

  test do
    cp "#{share}/autoconf/autotest/autotest.m4", "autotest.m4"
    system "#{bin}/autoconf", "autotest.m4"
  end
end
