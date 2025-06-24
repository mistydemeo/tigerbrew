class Asciidoc < Formula
  desc "Formatter/translator for text files to numerous formats"
  homepage "http://asciidoc.org/"
  url "https://downloads.sourceforge.net/project/asciidoc/asciidoc/8.6.9/asciidoc-8.6.9.tar.gz"
  sha256 "78db9d0567c8ab6570a6eff7ffdf84eadd91f2dfc0a92a2d0105d323cab4e1f0"


  head do
    url "https://github.com/asciidoc/asciidoc.git"
    depends_on "autoconf" => :build
  end

  depends_on "docbook"

  option "with-docbook-xsl", "Install DTDs to generate manpages"
  depends_on "docbook-xsl" => :optional

  def install
    system "autoconf" if build.head?
    system "./configure", "--prefix=#{prefix}"

    # otherwise OS X's xmllint bails out
    inreplace "Makefile", "-f manpage", "-f manpage -L"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
      If you intend to process AsciiDoc files through an XML stage
      (such as a2x for manpage generation) you need to add something
      like:

        export XML_CATALOG_FILES=#{etc}/xml/catalog

      to your shell rc file so that xmllint can find AsciiDoc's
      catalog files.

      See `man 1 xmllint' for more.
    EOS
  end

  test do
    (testpath/"test.txt").write("== Hello World!")
    system "#{bin}/asciidoc", "-b", "html5", "-o", "test.html", "test.txt"
    assert_match /\<h2 id="_hello_world"\>Hello World!\<\/h2\>/, File.read("test.html")
  end
end
