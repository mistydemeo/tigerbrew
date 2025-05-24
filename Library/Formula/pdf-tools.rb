class PdfTools < Formula
  desc "Emacs support library for PDF files"
  homepage "https://github.com/politza/pdf-tools"
  url "https://github.com/politza/pdf-tools/archive/v0.60.tar.gz"
  sha256 "3deff1183d69e942a9b9d94897e7aab73550574f953823815f5df925852d13f9"


  depends_on "pkg-config" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "cairo"
  depends_on "poppler"

  def install
    system "make"

    prefix.install "pdf-tools-#{version}.tar"
    (prefix/"elpa").mkpath
    system "tar", "--strip-components=1", "-xf", "#{prefix}/pdf-tools-#{version}.tar", "-C", "#{prefix}/elpa"
  end

  def caveats; <<-EOS.undent
    To install to your Emacs run:
      emacs -Q --batch --eval "(package-install-file \\"#{prefix}/pdf-tools-#{version}.tar\\")"
    EOS
  end
end
