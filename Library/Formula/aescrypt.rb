class Aescrypt < Formula
  desc "Program for encryption/decryption"
  homepage "http://aescrypt.sourceforge.net/"
  url "http://aescrypt.sourceforge.net/aescrypt-0.7.tar.gz"
  sha256 "7b17656cbbd76700d313a1c36824a197dfb776cadcbf3a748da5ee3d0791b92d"


  def install
    system "./configure"
    system "make"
    bin.install "aescrypt", "aesget"
  end

  test do
    (testpath/"key").write "kk=12345678901234567890123456789abc0"

    require "open3"
    Open3.popen3("#{bin}/aescrypt", "-k", testpath/"key") do |stdin, stdout, _|
      stdin.write("hello")
      stdin.close
      # we can't predict the output
      stdout.read.length > 0
    end
  end
end
