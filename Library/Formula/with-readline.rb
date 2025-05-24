class WithReadline < Formula
  desc "Allow GNU Readline to be used with arbitrary programs"
  homepage "http://www.greenend.org.uk/rjk/sw/withreadline.html"
  url "http://www.greenend.org.uk/rjk/sw/with-readline-0.1.1.tar.gz"
  sha256 "d12c71eb57ef1dbe35e7bd7a1cc470a4cb309c63644116dbd9c88762eb31b55d"
  revision 1


  depends_on "readline"

  option :universal

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "echo 'exit' | #{bin}/with-readline /usr/bin/expect"
  end
end
