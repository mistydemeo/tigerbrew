class Scheme48 < Formula
  desc "Scheme byte-code interpreter"
  homepage "http://www.s48.org/"
  url "https://s48.org/1.9.3/scheme48-1.9.3.tgz"
  sha256 "6ef5a9f3fca14110b0f831b45801d11f9bdfb6799d976aa12e4f8809daf3904c"

  conflicts_with "gambit-scheme", :because => "both install `scheme-r5rs` binaries"
  conflicts_with "scsh", :because => "both install include/scheme48.h"

  # Use the included PDF/PS/HTML files and skip regeneration which requires LaTeX
  patch :p0, :DATA

  option "with-check", 'Execute "make check" before installing'

  def install
    ENV.deparallelize
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "check" if build.with? "check"
    system "make", "install"
  end
end
__END__
--- Makefile.in.orig	2025-05-24 14:09:09.000000000 +0100
+++ Makefile.in	2025-05-24 14:09:44.000000000 +0100
@@ -470,7 +470,7 @@
 
 doc: doc/manual.pdf doc/manual.ps doc/html/manual.html
 
-install: install-no-doc install-doc
+install: install-no-doc
 
 install-no-doc: enough dirs
 # install the VM
@@ -535,10 +535,6 @@
 # install the documentation
 	$(srcdir)/mkinstalldirs $(DESTDIR)$(docdir)
 	$(INSTALL_DATA) $(srcdir)/COPYING $(DESTDIR)$(docdir)
-
-install-doc: dirs doc
-	$(srcdir)/mkinstalldirs $(DESTDIR)$(docdir)
-	$(INSTALL_DATA) $(srcdir)/COPYING $(DESTDIR)$(docdir)
 	$(INSTALL_DATA) $(srcdir)/doc/manual.pdf $(DESTDIR)$(docdir)
 	$(INSTALL_DATA) $(srcdir)/doc/manual.ps $(DESTDIR)$(docdir)
 	for f in $(srcdir)/doc/html/*; do \
