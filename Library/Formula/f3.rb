class F3 < Formula
  desc "Test various flash cards"
  homepage "http://oss.digirati.com.br/f3/"
  url "https://github.com/AltraMayor/f3/archive/v5.0.tar.gz"
  sha256 "5febf7d2b822f2f2b9208dfd6c28e026a5f3797c044ca20912b9b93628c1f544"

  head "https://github.com/AltraMayor/f3.git"


  def install
    system "make", "all"
    bin.install %w[f3read f3write]
    man1.install "f3read.1"
    man1.install_symlink "f3read.1" => "f3write.1"
  end

  test do
    system "#{bin}/f3read", testpath
  end
end
