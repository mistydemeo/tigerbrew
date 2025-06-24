class Coccinelle < Formula
  desc "Program matching and transformation engine for C code"
  homepage "http://coccinelle.lip6.fr/"
  url "http://coccinelle.lip6.fr/distrib/coccinelle-1.0.0-rc21.tgz"
  sha256 "a6609a1f800f84d058c9b395edd0597171594b685f551a9b9c03728a1b416783"
  revision 1


  depends_on "ocaml"
  depends_on "camlp4"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--enable-ocaml",
                          "--enable-opt",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end
