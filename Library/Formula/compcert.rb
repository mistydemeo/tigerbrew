class Compcert < Formula
  desc "CompCert C verified compiler"
  homepage "http://compcert.inria.fr"
  url "https://github.com/AbsInt/CompCert/archive/v2.5.tar.gz"
  sha256 "36847b00fa5436ac8e052489b728adef2bc68064fe22dbdc18bf22256856fd95"


  depends_on "ocaml" => :build
  depends_on "coq" => :build
  depends_on "menhir" => :build

  def install
    ENV.permit_arch_flags

    # Compcert's configure script hard-codes gcc. On Lion and under, this
    # creates problems since XCode's gcc does not support CFI,
    # but superenv will trick it into using clang which does. This
    # causes problems with the compcert compiler at runtime.
    inreplace "configure", "${toolprefix}gcc", "${toolprefix}#{ENV.cc}"

    system "./configure", "-prefix", prefix, "ia32-macosx"
    system "make", "all"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      int printf(const char *fmt, ...);
      int main(int argc, char** argv) {
        printf("Hello, world!\\n");
        return 0;
      }
    EOS
    system "#{bin}/ccomp", "test.c", "-o", "test"
    system "./test"
  end
end
