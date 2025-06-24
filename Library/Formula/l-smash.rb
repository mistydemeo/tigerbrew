class LSmash < Formula
  desc "Tool for working with MP4 files"
  homepage "https://l-smash.github.io/l-smash/"
  url "https://github.com/l-smash/l-smash.git", :shallow => false,
    :tag => "v2.9.1",
    :revision => "4cea08d264933634db5bc06da9d8d88fb5ddae07"
  head "https://github.com/l-smash/l-smash.git"


  def install
    system "./configure", "--prefix=#{prefix}", "--enable-shared"
    system "make", "install"
  end

  test do
    system "#{bin}/boxdumper", "-v"
    system "#{bin}/muxer", "-v"
    system "#{bin}/remuxer", "-v"
    system "#{bin}/timelineeditor", "-v"
  end
end
