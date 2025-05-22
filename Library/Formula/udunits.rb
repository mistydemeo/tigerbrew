class Udunits < Formula
  desc "Unidata unit conversion library"
  homepage "https://www.unidata.ucar.edu/software/udunits/"
  url "ftp://ftp.unidata.ucar.edu/pub/udunits/udunits-2.2.19.tar.gz"
  sha256 "9449d50a5d408e8e8dce0953b5462071bab96d92d921808c6bce7e33a3524e90"


  option "with-html-docs", "Installs html documentation"
  option "with-pdf-docs", "Installs pdf documentation"

  deprecated_option "html-docs" => "with-html-docs"
  deprecated_option "pdf-docs" => "with-pdf-docs"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    targets = ["install"]
    targets << "install-html" if build.include? "html-docs"
    targets << "install-pdf" if build.include? "pdf-docs"
    system "make", *targets
  end

  test do
    assert_match(/1 kg = 1000 g/, shell_output("#{bin}/udunits2 -H kg -W g"))
  end
end
