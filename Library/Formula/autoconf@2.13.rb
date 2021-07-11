class AutoconfAT213 < Formula
  desc "Automatic configure script builder"
  homepage "https://www.gnu.org/software/autoconf/"
  url "https://ftp.gnu.org/gnu/autoconf/autoconf-2.13.tar.gz"
  mirror "https://ftpmirror.gnu.org/autoconf/autoconf-2.13.tar.gz"
  sha256 "f0611136bee505811e9ca11ca7ac188ef5323a8e2ef19cffd3edb3cf08fd791e"

  bottle do
    cellar :any_skip_relocation
    revision 1
    sha256 "1ea8c751806adc1ee85dcfef1b66d2d8aaed52d9848362635bed0251b7437fa4" => :mojave
    sha256 "180a5d234c513e34952d639cfbcb5c486d64ad814d3d422b6cf86d048c0267c8" => :high_sierra
    sha256 "1631e2f720355ef11b150ebddde824c02eab44a336203bcdb5282e4784ecbcd9" => :sierra
    sha256 "f6b148c2bcf08f0e143a4757fa6784bf9e0d780d5ca8ec8cd97c042316c50d84" => :el_capitan
    sha256 "f6b148c2bcf08f0e143a4757fa6784bf9e0d780d5ca8ec8cd97c042316c50d84" => :yosemite
  end

  # Tiger's m4 is too old.
  depends_on "m4" if MacOS.version == :tiger

  keg_only :provided_until_xcode43

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--program-suffix=213",
                          "--prefix=#{prefix}",
                          "--infodir=#{pkgshare}/info",
                          "--datadir=#{pkgshare}"
    system "make", "install"
  end

  test do
    assert_match "Usage: autoconf", shell_output("#{bin}/autoconf213 --help 2>&1")
  end
end
