class BibTool < Formula
  desc "Manipulates BibTeX databases"
  homepage "http://www.gerd-neugebauer.de/software/TeX/BibTool/index.en.html"
  url "https://github.com/ge-ne/bibtool/releases/download/BibTool_2_61/BibTool-2.61.tar.gz"
  sha256 "8eaf351f1685078345a4446346559698fb58d8d1dfdf057418e5221132f9a8a4"


  def install
    system "./configure", "--prefix=#{prefix}", "--without-kpathsea"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.bib").write <<-EOS.undent
      @article{Homebrew,
          title   = {Something},
          author  = {Someone},
          journal = {Something},
          volume  = {1},
          number  = {2},
          pages   = {3--4}
      }
    EOS
    system "#{bin}/bibtool", "test.bib"
  end
end
