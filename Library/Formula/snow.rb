class Snow < Formula
  desc "Whitespace steganography: coded messages using whitespace"
  homepage "http://www.darkside.com.au/snow/"
  url "http://www.darkside.com.au/snow/snow-20130616.tar.gz"
  sha256 "c0b71aa74ed628d121f81b1cd4ae07c2842c41cfbdf639b50291fc527c213865"


  def install
    system "make"
    bin.install "snow"
    man1.install "snow.1"
  end

  test do
    touch "in.txt"
    touch "out.txt"
    system "#{bin}/snow", "-C", "-m", "'Secrets Abound Here'", "-p",
           "'hello world'", "in.txt", "out.txt"
    # The below should get the response 'Secrets Abound Here' when testing.
    system "#{bin}/snow", "-C", "-p", "'hello world'", "out.txt"
  end
end
