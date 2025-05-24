class Ats2Postiats < Formula
  desc "ATS programming language implementation"
  homepage "http://www.ats-lang.org/"
  url "https://downloads.sourceforge.net/project/ats2-lang/ats2-lang/ats2-postiats-0.2.3/ATS2-Postiats-0.2.3.tgz"
  sha256 "a2a50305ddfc8c88d475e0378a9f476887d11c0a64f381b849f2b9f1746258cd"


  depends_on "gmp"

  fails_with :clang do
    cause "Trying to compile this with Clang is failure-galore."
  end

  def install
    ENV.deparallelize

    system "./configure", "--prefix=#{prefix}"

    # Disable GC support for patsopt
    # https://github.com/githwxi/ATS-Postiats/issues/76
    system "make", "GCFLAG=-D_ATS_NGC", "all"
    system "make", "install"
  end

  test do
    (testpath/"hello.dats").write <<-EOS.undent
      val _ = print ("Hello, world!\n")
      implement main0 () = ()
    EOS
    system "#{bin}/patscc", "hello.dats", "-o", "hello"
    assert_match "Hello, world!", shell_output(testpath/"hello")
  end
end
