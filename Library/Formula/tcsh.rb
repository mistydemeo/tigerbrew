class Tcsh < Formula
  desc "Enhanced, fully compatible version of the Berkeley C shell"
  homepage "http://www.tcsh.org/"
  url "ftp://ftp.astron.com/pub/tcsh/tcsh-6.20.00.tar.gz"
  mirror "https://ftp.osuosl.org/pub/blfs/conglomeration/tcsh/tcsh-6.20.00.tar.gz"
  sha256 "b89de7064ab54dac454a266cfe5d8bf66940cb5ed048d0c30674ea62e7ecef9d"

  bottle do
    sha256 "9ea07dfb5815b5cfda4c022870a31fce1e1e66109d6afd21d45870b6566eef50" => :tiger_g3
    sha256 "e574d87dd70e6604f675033fcea4bd3f7529242dd868d705a8bae694f87f7a03" => :tiger_altivec
    sha256 "2ff1a8f5dbd9a71f555009b7ee509dc033953d4558a3fed85f74781a12942c5a" => :tiger_g5
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--sysconfdir=#{etc}"
    system "make", "install"
  end

  test do
    (testpath/"test.csh").write <<~EOS
      #!#{bin}/tcsh -f
      set ARRAY=( "t" "e" "s" "t" )
      foreach i ( 1 2 3 4 )
        echo -n $ARRAY[$i]
      end
    EOS
    assert_equal "test", shell_output("#{bin}/tcsh ./test.csh")
  end
end
