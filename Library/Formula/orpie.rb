class Orpie < Formula
  desc "RPN calculator for the terminal"
  homepage "http://pessimization.com/software/orpie/"
  url "http://pessimization.com/software/orpie/orpie-1.5.2.tar.gz"
  sha256 "de557fc7f608c6cb1f44a965d3ae07fc6baf2b02a0d7994b89d6a0e0d87d3d6d"


  depends_on "gsl"
  depends_on "ocaml"
  depends_on "camlp4" => :build

  def install
    ENV.deparallelize
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end
