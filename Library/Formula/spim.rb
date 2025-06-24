class Spim < Formula
  desc "MIPS32 simulator"
  homepage "http://spimsimulator.sourceforge.net/"
  # No source code tarball exists
  url "http://svn.code.sf.net/p/spimsimulator/code", :revision => 641
  version "9.1.13"


  def install
    bin.mkpath
    cd "spim" do
      system "make", "EXCEPTION_DIR=#{share}"
      system "make", "install", "BIN_DIR=#{bin}",
                                "EXCEPTION_DIR=#{share}",
                                "MAN_DIR=#{man1}"
    end
  end
end
