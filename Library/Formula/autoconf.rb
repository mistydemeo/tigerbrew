class Autoconf < Formula
  desc "Automatic configure script builder"
  homepage "https://www.gnu.org/software/autoconf"
  url "https://ftpmirror.gnu.org/autoconf/autoconf-2.71.tar.xz"
  mirror "https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.xz"
  sha256 "f14c83cfebcc9427f2c3cea7258bd90df972d92eb26752da4ddad81c87a0faa4"

  bottle do
    cellar :any_skip_relocation
    sha256 "640cfafe965e3913c90f07da98494d2906114ae082169f31b84150c47bdab3a4" => :tiger_altivec
  end

  # Tiger's m4 is too old.
  depends_on "m4" if MacOS.version == :tiger

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
