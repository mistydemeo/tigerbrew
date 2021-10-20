class Expat < Formula
  desc "XML 1.0 parser"
  homepage "http://www.libexpat.org"
  url "https://github.com/libexpat/libexpat/releases/download/R_2_1_0/expat-2.1.0.tar.gz"
  mirror "https://ftp.osuosl.org/pub/blfs/conglomeration/expat/expat-2.1.0.tar.gz"
  sha256 "823705472f816df21c8f6aa026dd162b280806838bb55b3432b0fb1fcca7eb86"
  revision 1

  head "https://github.com/libexpat/libexpat.git"

  bottle do
    cellar :any
    revision 1
    sha256 "029429201dd20a3b3b4a8cd17a88deb891c8b5c9a51d9807e72c26952b45f552" => :tiger_altivec
    sha256 "cd7e2201781cbfa541a75d7c794b0149e141f426c1785186037311f381e200e0" => :leopard_g3
    sha256 "3cba71ebb2c11fc7dd9137f844861b5fd7b2a55c5e37af7506556e339a33ae7e" => :leopard_altivec
  end

  keg_only :provided_by_osx, "OS X includes Expat 1.5." if MacOS.version > :tiger

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
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
    system ENV.cc, "test.c", "-lexpat", "-o", "test"
    assert_equal "tag:str|data:Hello, world!|", shell_output("./test")
  end
end
