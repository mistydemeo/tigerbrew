class Irssi < Formula
  desc "Modular IRC client"
  homepage "http://irssi.org/"
  url "https://codeberg.org/irssi/irssi/releases/download/1.4.5/irssi-1.4.5.tar.xz"
  sha256 "72a951cb0ad622785a8962801f005a3a412736c7e7e3ce152f176287c52fe062"

  head do
    url "https://github.com/irssi/irssi.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
    depends_on "lynx" => :build
  end

  bottle do
  end

  # New pm_to_blib syntax in Perl 5.42
  # https://github.com/irssi/irssi/issues/1573
  patch :p1, :DATA

  option "with-dante", "Build with SOCKS support"
  option "without-perl", "Build without perl support"

  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "openssl3"
  depends_on "dante" => :optional
  depends_on "ncurses"
  depends_on "perl" if build.with? "perl"

  if build.with? "perl"
    # Restore locale after loading Perl
    # https://github.com/irssi/irssi/pull/1498
    patch do
      url "https://codeberg.org/irssi/irssi/releases/download/1.4.5/perl-again.patch"
      sha256 "df7433f0b0bd326613c36f3104b996f5fdbbe8c49f0449ca8700816b47d50e56"
    end
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --with-proxy
      --enable-true-color
      --with-socks=#{build.with?("dante") ? "yes" : "no"}
    ]

    if build.with? "perl"
      args << "--with-perl=yes"
      args << "--with-perl-lib=#{lib}/perl5/site_perl"
    else
      args << "--with-perl=no"
    end

    # confuses Perl library path configuration
    # https://github.com/Homebrew/homebrew/issues/34685
    ENV.delete "PERL_MM_OPT"

    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    # "make" and "make install" must be done separately on some systems
    system "make"
    system "make", "install"
  end

  test do
    IO.popen("#{bin}/irssi --connect=irc.libera.chat", "w") do |pipe|
      pipe.puts "/quit\n"
      pipe.close_write
    end

    # This is not how you'd use Perl with Irssi but it is enough to be
    # sure the Perl element didn't fail to compile, which is needed
    # because upstream treats Perl build failures as non-fatal.
    # To debug a Perl problem copy the following test at the end of the install
    # block to surface the relevant information from the build warnings.
    ENV["PERL5LIB"] = lib/"perl5/site_perl"
    system "perl", "-e", "use Irssi"
  end
end
__END__
--- a/src/perl/Makefile_silent.pm
+++ b/src/perl/Makefile_silent.pm
@@ -22,7 +22,7 @@ my $verb = $AM_DEFAULT_VERBOSITY;
     }
     sub pm_to_blib {
 	my $ret = shift->SUPER::pm_to_blib(@_);
-	$ret =~ s{^(\t(?:- ?)?)(?:\$\(NOECHO\) ?)?(.*-e ['"]pm_to_blib(.*\\\n)*.*)$}{$1\$(PL_AM_V_BLIB)$2\$(PL_AM_V_BLIB_Hide)}mg;
+	$ret =~ s{^(\t(?:- ?)?)(?:\$\(NOECHO\) ?)?((?:\\\r?\n|.)*-e ['"]pm_to_blib(.*\\\n)*.*)$}{$1\$(PL_AM_V_BLIB)$2\$(PL_AM_V_BLIB_Hide)}mg;
 	$ret
     }
     sub post_constants {
