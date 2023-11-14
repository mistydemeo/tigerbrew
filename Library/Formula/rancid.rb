class Rancid < Formula
  desc "Really Awesome New Cisco confIg Differ"
  homepage "http://www.shrubbery.net/rancid/"
  url "https://shrubbery.net/pub/rancid/rancid-3.13.tar.gz"
  mirror "https://mirrors.edge.kernel.org/debian/pool/main/r/rancid/rancid_3.13.orig.tar.gz"
  sha256 "7241d2972b1f6f76a28bdaa0e7942b1257e08b404a15d121c9dee568178f8bf5"

  bottle do
    cellar :any_skip_relocation

    sha256 "cab73cea6e86c68592958170f9a9aeae13978928951a9ce107adc35ebb8c1188" => :tiger_altivec
  end

  conflicts_with "par", :because => "both install `par` binaries"

  depends_on "git"
  depends_on "openssh"
  depends_on "perl" # Socket version 2.006 required

  def install
    system "./configure", "--prefix=#{prefix}", "--exec-prefix=#{prefix}", "--mandir=#{man}", "--with-git"
    system "make", "install"
  end

  test do
    (testpath/"rancid.conf").write <<-EOS.undent
      BASEDIR=#{testpath}; export BASEDIR
      CVSROOT=$BASEDIR/CVS; export CVSROOT
      LOGDIR=$BASEDIR/logs; export LOGDIR
      RCSSYS=git; export RCSSYS
      LIST_OF_GROUPS="backbone aggregation switches"
    EOS
    system "#{bin}/rancid-cvs", "-f", testpath/"rancid.conf"
  end
end
