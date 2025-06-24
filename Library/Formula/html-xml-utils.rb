class HtmlXmlUtils < Formula
  desc "Tools for manipulating HTML and XML files"
  homepage "http://www.w3.org/Tools/HTML-XML-utils/"
  url "http://www.w3.org/Tools/HTML-XML-utils/html-xml-utils-6.7.tar.gz"
  sha256 "92af4886fcada0e2fc35308def4d02baedd9889d2e4c957b07b77a60fbdacd99"


  def install
    ENV.append "CFLAGS", "-std=gnu89"
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"
    ENV.j1 # install is not thread-safe
    system "make", "install"
  end

  test do
    assert_equal "&#20320;&#22909;", pipe_output("#{bin}/xml2asc", "你好")
  end
end
