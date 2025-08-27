class Expat < Formula
  desc "XML 1.0 parser"
  homepage "https://libexpat.github.io"
  url "https://github.com/libexpat/libexpat/releases/download/R_2_7_1/expat-2.7.1.tar.bz2"
  sha256 "45c98ae1e9b5127325d25186cf8c511fa814078e9efeae7987a574b482b79b3d"
  license "MIT"

  head "https://github.com/libexpat/libexpat.git"

  bottle do
    sha256 "6d321ffb4d4404cd527d10f5c75cfc9c952a881a7635ff374bb731cf9117e5fd" => :tiger_altivec
  end

  keg_only :provided_by_osx, "OS X includes Expat 1.5." if MacOS.version > :tiger

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--without-tests" # Needs a C++11 compiler
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <stdio.h>
      #include "expat.h"

      static void XMLCALL my_StartElementHandler(
        void *userdata,
        const XML_Char *name,
        const XML_Char **atts)
      {
        printf("tag:%s|", name);
      }

      static void XMLCALL my_CharacterDataHandler(
        void *userdata,
        const XML_Char *s,
        int len)
      {
        printf("data:%.*s|", len, s);
      }

      int main()
      {
        static const char str[] = "<str>Hello, world!</str>";
        int result;

        XML_Parser parser = XML_ParserCreate("utf-8");
        XML_SetElementHandler(parser, my_StartElementHandler, NULL);
        XML_SetCharacterDataHandler(parser, my_CharacterDataHandler);
        result = XML_Parse(parser, str, sizeof(str), 1);
        XML_ParserFree(parser);

        return result;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-I#{include}", "-lexpat", "-o", "test"
    assert_equal "tag:str|data:Hello, world!|", shell_output("./test")
  end
end
