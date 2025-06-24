class Julius < Formula
  desc "Two-pass large vocabulary continuous speech recognition engine"
  homepage "http://julius.osdn.jp"
  url "http://dl.osdn.jp/julius/60273/julius-4.3.1.tar.gz"
  sha256 "4bf77c7b91f4bb0686c375c70bd4f2077e7de7db44f60716af9f3660f65a6253"


  depends_on "libsndfile"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--mandir=#{man}",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    shell_output("#{bin}/julius.dSYM --help", 1)
  end
end
