class Mp3wrap < Formula
  desc "Wrap two or more mp3 files in a single large file"
  homepage "http://mp3wrap.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/mp3wrap/mp3wrap/mp3wrap%200.5/mp3wrap-0.5-src.tar.gz"
  sha256 "1b4644f6b7099dcab88b08521d59d6f730fa211b5faf1f88bd03bf61fedc04e7"


  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end

  test do
    source = test_fixtures("test.mp3")
    system "#{bin}/mp3wrap", "#{testpath}/t.mp3", source, source
    assert File.exist? testpath/"t_MP3WRAP.mp3"
  end
end
