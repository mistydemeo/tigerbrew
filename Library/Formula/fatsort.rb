class Fatsort < Formula
  desc "Sorts FAT16 and FAT32 partitions"
  homepage "http://fatsort.sourceforge.net/"
  url "https://sourceforge.net/code-snapshots/svn/f/fa/fatsort/code/fatsort-code-r522-trunk.zip"
  sha256 "341ab8b9dc04b53d47abcb282c7cb027a2bae982e1ded3083d62aa7c260a1bde"

  depends_on "help2man"

  def install
    system "make", "CC=#{ENV.cc}"
    bin.install "src/fatsort"
    man1.install "man/fatsort.1"
  end
end
