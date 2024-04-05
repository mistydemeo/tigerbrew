class Cscope < Formula
  desc "Tool for browsing source code"
  homepage "https://cscope.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/cscope/cscope/v15.9/cscope-15.9.tar.gz"
  sha256 "c5505ae075a871a9cd8d9801859b0ff1c09782075df281c72c23e72115d9f159"
  license "BSD-3-Clause"

  bottle do
    cellar :any_skip_relocation
  end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <stdio.h>
      #include <stdlib.h>

      void func()
      {
        printf("Hello World!");
      }

      int main()
      {
        func();
        return 0;
      }
    EOS
    (testpath/"cscope.files").write ("./test.c\n")
    system "#{bin}/cscope", "-b", "-k"
    assert_match /test\.c.*func/, shell_output("#{bin}/cscope -L1func")
  end
end
