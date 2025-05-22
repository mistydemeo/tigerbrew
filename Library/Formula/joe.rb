class Joe < Formula
  desc "Joe's Own Editor (JOE)"
  homepage "http://joe-editor.sourceforge.net/index.html"
  url "https://downloads.sourceforge.net/project/joe-editor/JOE%20sources/joe-4.0/joe-4.0.tar.gz"
  sha256 "c556adff77fd97bf1b86198de6cb82e0b92cda18579c4fef6c83b608d2ed2915"


  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/stringify"
  end
end
