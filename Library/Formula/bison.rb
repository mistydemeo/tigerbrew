require 'formula'

class Bison < Formula
  homepage 'http://www.gnu.org/software/bison/'
  url 'http://ftpmirror.gnu.org/bison/bison-3.0.1.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/bison/bison-3.0.1.tar.gz'
  sha1 '0191d1679525b1e05bb35265a71e7475e7cb1432'

  if MacOS.version < :leopard
    depends_on 'automake'
    # "It also requires GNU Autoconf, GNU m4 and Perl in order to run"
    depends_on 'autoconf'
    depends_on 'homebrew/dupes/m4'
  end

  keg_only :provided_by_osx, 'Some formulae require a newer version of bison.'

  # Disable perl -f flag, which Tiger's perl doesn't recognize.
  # Applied upstream: http://lists.gnu.org/archive/html/bug-bison/2013-08/msg00010.html
  def patches; DATA; end

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
