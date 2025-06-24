class LinkGrammar < Formula
  desc "Carnegie Mellon University's link grammar parser"
  homepage "http://www.abisource.com/projects/link-grammar/"
  url "http://www.abisource.com/downloads/link-grammar/4.7.14/link-grammar-4.7.14.tar.gz"
  sha256 "6fe8b46c6f134c5c1e43fc0eaae048fe746c533a0cae8d63ad07fc2a3dff7667"


  depends_on "pkg-config" => :build
  depends_on :ant => :build

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/link-parser", "--version"
  end
end
