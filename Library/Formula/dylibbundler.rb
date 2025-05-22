class Dylibbundler < Formula
  desc "Utility to bundle libraries into executables for OS X"
  homepage "https://github.com/auriamg/macdylibbundler"
  url "https://downloads.sourceforge.net/project/macdylibbundler/macdylibbundler/0.4.4/dylibbundler-0.4.4.zip"
  sha256 "65d050327df99d12d96ae31a693bace447f4115e6874648f1b3960a014362200"
  head "https://github.com/auriamg/macdylibbundler.git"


  def install
    system "make"
    bin.install "dylibbundler"
  end

  test do
    system "#{bin}/dylibbundler", "-h"
  end
end
