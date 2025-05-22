class Parallel < Formula
  desc "GNU parallel shell command"
  homepage "https://savannah.gnu.org/projects/parallel/"
  url "http://ftpmirror.gnu.org/parallel/parallel-20150822.tar.bz2"
  mirror "https://ftp.gnu.org/gnu/parallel/parallel-20150822.tar.bz2"
  sha256 "ad9007530d87687160fd8def58721acdac244c151b6c007f35068909bb5c47c6"
  head "http://git.savannah.gnu.org/r/parallel.git"


  conflicts_with "moreutils", :because => "both install a 'parallel' executable."

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_equal "test\ntest\n",
                 shell_output("#{bin}/parallel --will-cite echo ::: test test")
  end
end
