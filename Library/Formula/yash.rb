class Yash < Formula
  desc "Yet another shell: a POSIX-compliant command-line shell"
  homepage "http://yash.osdn.jp"
  url "http://dl.osdn.jp/yash/62651/yash-2.37.tar.gz"
  sha256 "b976692de245ad3fb17bf87eb8b2e4c9bba4537e3820d488624c868e7408faaa"


  def install
    system "sh", "./configure",
            "--prefix=#{prefix}",
            "--enable-alias",
            "--enable-array",
            "--enable-dirstack",
            "--enable-help",
            "--enable-history",
            "--enable-lineedit",
            "--disable-nls",
            "--enable-printf",
            "--enable-socket",
            "--enable-test",
            "--enable-ulimit"
    system "make", "install"
  end

  test do
    system "#{bin}/yash", "-c", "echo hello world"
  end
end
