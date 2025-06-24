class Bibtexconv < Formula
  desc "BibTeX file converter"
  homepage "https://www.uni-due.de/~be0001/bibtexconv/"
  url "https://www.uni-due.de/~be0001/bibtexconv/download/bibtexconv-1.1.3.tar.gz"
  sha256 "f7fd69ff99cd48a77e53aed4219defaf1f45485a07978faec01c2b9074886e03"
  revision 1


  head do
    url "https://github.com/dreibh/bibtexconv.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  depends_on "openssl"

  def install
    if build.head?
      inreplace "bootstrap", "/usr/bin/glibtoolize", Formula["libtool"].bin/"glibtoolize"
      system "./bootstrap"
    end
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    ENV.j1 # serialize folder creation
    system "make", "install"
  end

  test do
    cp "#{Formula["bibtexconv"].opt_share}/doc/bibtexconv/examples/ExampleReferences.bib", testpath

    system bin/"bibtexconv", "#{testpath}/ExampleReferences.bib",
                             "-export-to-bibtex=UpdatedReferences.bib",
                             "-check-urls", "-only-check-new-urls",
                             "-non-interactive"
  end
end
