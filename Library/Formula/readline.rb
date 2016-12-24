class Readline < Formula
  desc "Library for command-line editing"
  homepage "https://tiswww.case.edu/php/chet/readline/rltop.html"
  url "https://ftpmirror.gnu.org/readline/readline-7.0.tar.gz"
  mirror "https://ftp.gnu.org/gnu/readline/readline-7.0.tar.gz"
  sha256 "750d437185286f40a369e1e4f4764eda932b9459b5ec9a731628393dd3d32334"

  bottle do
    cellar :any
    sha256 "f36867f7a2762620894058678f400aa945c9a6930a7a33f7e74d02e12639bbb4" => :tiger_altivec
    sha256 "87370403df816b715cb920cce228a31240e7d6eab976bf32b92e2f77050dac06" => :leopard_g3
    sha256 "3d347f4be190c3881c6240f3037e4e5b474b47c36740cf21595ba4122e280205" => :leopard_altivec
  end

  keg_only :shadowed_by_osx, <<-EOS.undent
    OS X provides the BSD libedit library, which shadows libreadline.
    In order to prevent conflicts when programs look for libreadline we are
    defaulting this GNU Readline installation to keg-only.
  EOS

  def install
    ENV.universal_binary
    system "./configure", "--prefix=#{prefix}", "--enable-multibyte"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <stdio.h>
      #include <stdlib.h>
      #include <readline/readline.h>

      int main()
      {
        printf("%s\\n", readline("test> "));
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-lreadline", "-o", "test"
    assert_equal "Hello, World!", pipe_output("./test", "Hello, World!\n").strip
  end
end
