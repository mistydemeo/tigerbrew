class Lfe < Formula
  desc "A Concurrent Lisp for the Erlang VM"
  homepage "http://lfe.io/"
  url "https://github.com/lfe/lfe/archive/refs/tags/2.2.0.tar.gz"
  sha256 "5c9de979c64de245ac3ae2f9694559a116b538ca7d18bb3ef07716e0e3a696f3"

  head "https://github.com/lfe/lfe.git", :branch => "develop"

  # Skip on trying to run mandb which doesn't exist on OS X
  patch :p0, :DATA

  depends_on "erlang"

  def install
    system "make"
    system "make", "install", "PREFIX=#{prefix}", "MANINSTDIR=#{man}"
  end

  test do
    system bin/"lfe", "-eval", '"(io:format \"~p\" (list (* 2 (lists:foldl #\'+/2 0 (lists:seq 1 6)))))"'
  end
end
__END__
--- Makefile.orig	2025-04-21 18:59:15.000000000 +0100
+++ Makefile	2025-04-21 19:01:09.000000000 +0100
@@ -313,7 +313,7 @@
 ifeq (,$(findstring mandb,$(MANDB)))
 install-man: $(MANINSTDIR)/man1 $(MANINSTDIR)/man3 $(MANINSTDIR)/man7
 else
-install-man: $(MANINSTDIR)/man1 $(MANINSTDIR)/man3 $(MANINSTDIR)/man7 update-mandb
+install-man: $(MANINSTDIR)/man1 $(MANINSTDIR)/man3 $(MANINSTDIR)/man7
 endif
 	$(INSTALL_DATA) $(MANDIR)/*.1 $(MANINSTDIR)/man1/
 	$(INSTALL_DATA) $(MANDIR)/*.3 $(MANINSTDIR)/man3/
