class Cweb < Formula
  desc "Literate documentation system for C, C++, and Java"
  homepage "http://www-cs-faculty.stanford.edu/~uno/cweb.html"
  url "ftp://ftp.cs.stanford.edu/pub/cweb/cweb-3.64ad.tar.gz"
  sha256 "1f0bb7aa35b8d43b721d588ed5003620d38de1959652f23bac2847ffcb922c0f"


  def install
    ENV.deparallelize

    macrosdir = (share/"texmf/tex/generic")
    emacsdir = (share/"emacs/site-lisp/cweb")
    cwebinputs = (lib/"cweb")

    # make install doesn't use `mkdir -p` so this is needed
    [bin, man1, macrosdir, emacsdir, cwebinputs].each(&:mkpath)

    system "make", "install",
      "DESTDIR=#{bin}/",
      "MANDIR=#{man1}",
      "MANEXT=1",
      "MACROSDIR=#{macrosdir}",
      "EMACSDIR=#{emacsdir}",
      "CWEBINPUTS=#{cwebinputs}"
  end

  test do
    (testpath/"test.w").write <<-EOS.undent
      @* Hello World
      This is a minimal program written in CWEB.

      @c
      #include <stdio.h>
      void main() {
          printf("Hello world!");
      }
    EOS
    system bin/"ctangle", "test.w"
    system ENV.cc, "test.c", "-o", "hello"
    assert_equal "Hello world!", `./hello`
  end
end
