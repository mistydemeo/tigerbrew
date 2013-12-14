require 'formula'

class Bison < Formula
  homepage 'http://www.gnu.org/software/bison/'
  url 'http://ftpmirror.gnu.org/bison/bison-3.0.2.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/bison/bison-3.0.2.tar.gz'
  sha1 '4bbb9a1bdc7e4328eb4e6ef2479b3fe15cc49e54'

  if MacOS.version < :leopard
    depends_on 'automake'
    # "It also requires GNU Autoconf, GNU m4 and Perl in order to run"
    depends_on 'autoconf'
    depends_on 'homebrew/dupes/m4'
  end

  keg_only :provided_by_osx, 'Some formulae require a newer version of bison.'

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

__END__
diff --git a/examples/local.mk b/examples/local.mk
index 05e28e1..c79c800 100644
--- a/examples/local.mk
+++ b/examples/local.mk
@@ -25,7 +25,7 @@ AM_CXXFLAGS =             \
 
 doc = $(top_srcdir)/doc/bison.texi
 extexi = $(top_srcdir)/examples/extexi
-extract = VERSION="$(VERSION)" $(PERL) -f $(extexi) $(doc) --
+extract = VERSION="$(VERSION)" $(PERL) $(extexi) $(doc) --
 extracted =
 CLEANFILES += $(extracted) examples/extracted.stamp
 examples/extracted.stamp: $(doc) $(extexi)
