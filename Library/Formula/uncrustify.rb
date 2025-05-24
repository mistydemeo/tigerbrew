class Uncrustify < Formula
  desc "Source code beautifier"
  homepage "http://uncrustify.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/uncrustify/uncrustify/uncrustify-0.61/uncrustify-0.61.tar.gz"
  sha256 "1df0e5a2716e256f0a4993db12f23d10195b3030326fdf2e07f8e6421e172df9"

  head "https://github.com/bengardner/uncrustify.git"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"t.c").write <<-EOS.undent
      #include <stdio.h>
      int main(void) {return 0;}
    EOS
    expected = <<-EOS.undent
      #include <stdio.h>
      int main(void) {
      \treturn 0;
      }
    EOS

    system "#{bin}/uncrustify", "-c", "#{share}/uncrustify/defaults.cfg", "t.c"
    assert_equal expected, File.read("#{testpath}/t.c.uncrustify")
  end
end
