class Texi2html < Formula
  desc "Convert TeXinfo files to HTML"
  homepage "https://www.nongnu.org/texi2html/"
  url "http://download.savannah.gnu.org/releases/texi2html/texi2html-1.82.tar.gz"
  sha256 "6c7c94a2d88ffe218a33e91118c2b039336cbe3f2f8b4e3a78e4fd1502072936"

  bottle do
    cellar :any_skip_relocation
    sha256 "6dc3e72f8bc538ccbbf7488479cf5d28877640cef1d19282a59ddff2a77228a5" => :tiger_altivec
    sha256 "37a5199a826a4e6751f637332f77eaa64f166c61f97c663e56da372678ea6482" => :leopard_g3
    sha256 "0a9c1562ae122910318a97a19624f998a7dee16edb8f501d6ad4d52298b70070" => :leopard_altivec
  end

  keg_only :provided_pre_mountain_lion

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}",
                          "--mandir=#{man}", "--infodir=#{info}"
    system "make", "install"
  end

  test do
    system "#{bin}/texi2html", "--help"
  end
end
