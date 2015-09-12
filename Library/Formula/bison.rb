class Bison < Formula
  desc "Parser generator"
  homepage "https://www.gnu.org/software/bison/"
  url "http://ftpmirror.gnu.org/bison/bison-3.0.4.tar.gz"
  mirror "https://ftp.gnu.org/gnu/bison/bison-3.0.4.tar.gz"
  sha256 "b67fd2daae7a64b5ba862c66c07c1addb9e6b1b05c5f2049392cfd8a2172952e"

  bottle do
    sha256 "17488b69156f6fc91dd438c54920751399c23745f330487abd54c4cbcb49ff6a" => :el_capitan
    sha1 "4a2c74267f6adff751ed407b18ba5a7e21f756fa" => :yosemite
    sha1 "d8d02a4fce3fcdcdb8369fd8865f98ca95d12348" => :mavericks
    sha1 "77b214901733883a054619cc0075af60494d6fb8" => :mountain_lion
  end

  if MacOS.version < :leopard
    depends_on "automake"
    # "It also requires GNU Autoconf, GNU m4 and Perl in order to run"
    depends_on "autoconf"
    depends_on "homebrew/dupes/m4"
  end

  keg_only :provided_by_osx, "Some formulae require a newer version of bison."

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.y").write <<-EOS.undent
      %{ #include <iostream>
         using namespace std;
         extern void yyerror (char *s);
         extern int yylex ();
      %}
      %start prog
      %%
      prog:  //  empty
          |  prog expr '\\n' { cout << "pass"; exit(0); }
          ;
      expr: '(' ')'
          | '(' expr ')'
          |  expr expr
          ;
      %%
      char c;
      void yyerror (char *s) { cout << "fail"; exit(0); }
      int yylex () { cin.get(c); return c; }
      int main() { yyparse(); }
    EOS
    system "#{bin}/bison", "test.y"
    system ENV.cxx, "test.tab.c", "-o", "test"
    assert_equal "pass", shell_output("echo \"((()(())))()\" | ./test")
    assert_equal "fail", shell_output("echo \"())\" | ./test")
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
