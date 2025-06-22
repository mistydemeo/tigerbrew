class Libmxml < Formula
  desc "Mini-XML library"
  homepage "https://www.msweet.org/mxml/"
  url "https://www.msweet.org/files/project3/mxml-2.9.tar.gz"
  sha256 "cded54653c584b24c4a78a7fa1b3b4377d49ac4f451ddf170ebbc8161d85ff92"

  head "http://svn.msweet.org/mxml/"

  bottle do
    cellar :any
    sha1 "e1c87b1b1ec3e362656f7e5d9c14c99dec182ab8" => :yosemite
    sha1 "5d8a8bd17997790bb48c6142750ef9d2539d674b" => :mavericks
    sha1 "2f99f449b8730e5fc9e340671ca9ff2e6095c8f9" => :mountain_lion
  end

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
