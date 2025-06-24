class Libmxml < Formula
  desc "Mini-XML library"
  homepage "http://www.minixml.org/"
  url "https://www.msweet.org/files/project3/mxml-2.9.tar.gz"
  sha256 "cded54653c584b24c4a78a7fa1b3b4377d49ac4f451ddf170ebbc8161d85ff92"

  head "http://svn.msweet.org/mxml/"


  depends_on :xcode => :build # for docsetutil

  def install
    system "./configure", "--disable-debug",
                          "--enable-shared",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      int testfunc(char *string)
      {
        return string ? string[0] : 0;
      }
    EOS
    assert_match /testfunc/, shell_output("#{bin}/mxmldoc test.c")
  end
end
