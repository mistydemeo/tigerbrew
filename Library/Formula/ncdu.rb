class Ncdu < Formula
  desc "NCurses Disk Usage"
  homepage "https://dev.yorhel.nl/ncdu"
  url "https://dev.yorhel.nl/download/ncdu-1.19.tar.gz"
  sha256 "30363019180cde0752c7fb006c12e154920412f4e1b5dc3090654698496bb17d"

  bottle do
    cellar :any_skip_relocation
    sha256 "2a713a0552aba37fe6d8ef9e419169f6902c3402e1a58abba1971631173e16b9" => :tiger_altivec
  end

  head do
    url "git://g.blicky.net/ncdu.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
  end

  def install
    system "autoreconf", "-i" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ncdu -v")
  end
end
