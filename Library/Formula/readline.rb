class Readline < Formula
  desc "Library for command-line editing"
  homepage "https://tiswww.case.edu/php/chet/readline/rltop.html"
  url "https://ftpmirror.gnu.org/readline/readline-8.2.tar.gz"
  mirror "https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz"
  sha256 "3feb7171f16a84ee82ca18a36d7b9be109a52c04f492a053331d7d1095007c35"

  bottle do
    sha256 "368ef46f0edb4a2dfa186ef2f128c43066c037eb8729d3d5a5348288e5b1dddc" => :tiger_altivec
  end

  keg_only :shadowed_by_osx, <<-EOS.undent
    OS X provides the BSD libedit library, which shadows libreadline.
    In order to prevent conflicts when programs look for libreadline we are
    defaulting this GNU Readline installation to keg-only.
  EOS

  def install
    ENV.universal_binary
    # Since we don't set any CFLAGS on Intel, readline adds some
    # which break the build as they're not supported by GCC 4.2
    ENV.append_to_cflags "-g -O2" if Hardware::CPU.type == :intel
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
