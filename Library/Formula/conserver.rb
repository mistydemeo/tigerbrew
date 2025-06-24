class Conserver < Formula
  desc "Allows multiple users to watch a serial console at the same time"
  homepage "http://conserver.com"
  url "http://conserver.com/conserver-8.2.1.tar.gz"
  sha256 "251ae01997e8f3ee75106a5b84ec6f2a8eb5ff2f8092438eba34384a615153d0"


  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    console = fork do
      exec bin/"console", "-n", "-p", "8000", "test"
    end
    sleep 1
    Process.kill("TERM", console)
  end
end
