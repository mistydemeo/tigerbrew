class Ssdeep < Formula
  desc "Recursive piecewise hashing tool"
  homepage "http://ssdeep.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/ssdeep/ssdeep-2.13/ssdeep-2.13.tar.gz"
  sha256 "6e4ca94457cb50ff3343d4dd585473817a461a55a666da1c5a74667924f0f8c5"


  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    expected = <<-EOS.undent
      ssdeep,1.1--blocksize:hash:hash,filename
      192:15Jsxlk/azhE79EEfpm0sfQ+CfQoDfpw3RtU:15JsPz+7OEBCYLYYB7,"/usr/local/Cellar/ssdeep/2.13/include/fuzzy.h"
    EOS
    assert_equal expected, shell_output("#{bin}/ssdeep #{include}/fuzzy.h")
  end
end
