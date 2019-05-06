class Archey < Formula
  desc "Archey script for OS X"
  homepage "https://obihann.github.io/archey-osx/"
  url "https://github.com/obihann/archey-osx/archive/1.6.0.tar.gz"
  sha256 "0f0ffcf8c5f07610b98f0351dcb38bb8419001f40906d5dc4bfd28ef12dbd0f8"
  head "https://github.com/obihann/archey-osx.git"

  def install
    bin.install "bin/archey"
  end

  test do
    system "#{bin}/archey"
  end
end
