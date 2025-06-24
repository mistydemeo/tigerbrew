class Pkcrack < Formula
  desc "Implementation of an algorithm for breaking the PkZip cipher"
  homepage "https://www.unix-ag.uni-kl.de/~conrad/krypto/pkcrack.html"
  url "https://www.unix-ag.uni-kl.de/~conrad/krypto/pkcrack/pkcrack-1.2.2.tar.gz"
  sha256 "4d2dc193ffa4342ac2ed3a6311fdf770ae6a0771226b3ef453dca8d03e43895a"


  # This patch is to build correctly in OSX. I've changed #include<malloc.h> to
  # include<stdlib.h> because OSX doesn't have malloc.h.
  # I have sent to the author [conrad@unix-ag.uni-kl.de] for this patch at 2015/03/31.
  # Detail: https://gist.github.com/jtwp470/e998c720451f8ec849b0
  patch do
    url "https://gist.githubusercontent.com/jtwp470/e998c720451f8ec849b0/raw/012657af1dffd38db4e072a8b793661808a58d69/pkcrack_for_osx_brew.diff"
    sha256 "e0303d9adeffb2fb2a61a82ad040a3fec4edc23cae044ac1517b826c27fce412"
  end

  def install
    system "make", "-C", "src/"
    bin.install Dir["src/*"].select { |f| File.executable? f }
  end

  test do
    shell_output("pkcrack", 1)
  end
end
