class Lv < Formula
  desc "Powerful multi-lingual file viewer/grep"
  homepage "http://www.ff.iij4u.or.jp/~nrt/lv/"
  url "http://www.ff.iij4u.or.jp/~nrt/freeware/lv451.tar.gz"
  version "4.51"
  sha256 "e1cd2e27109fbdbc6d435f2c3a99c8a6ef2898941f5d2f7bacf0c1ad70158bcf"


  def install
    # zcat doesn't handle gzip'd data on OSX.
    # Reported upstream to nrt@ff.iij4u.or.jp
    inreplace "src/stream.c", 'gz_filter = "zcat"', 'gz_filter = "gzcat"'

    cd "build" do
      system "../src/configure", "--prefix=#{prefix}"
      system "make"
      bin.install "lv"
      bin.install_symlink "lv" => "lgrep"
    end

    man1.install "lv.1"
    (lib+"lv").install "lv.hlp"
  end
end
