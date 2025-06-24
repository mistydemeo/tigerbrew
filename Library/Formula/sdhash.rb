class Sdhash < Formula
  desc "Tool for correlating binary blobs of data"
  homepage "http://roussev.net/sdhash/sdhash.html"
  url "http://roussev.net/sdhash/releases/packages/sdhash-3.1.tar.gz"
  sha256 "b991d38533d02ae56e0c7aeb230f844e45a39f2867f70fab30002cfa34ba449c"
  revision 1


  depends_on "openssl"

  def install
    inreplace "Makefile" do |s|
      # Remove space between -L and the path (reported upstream)
      s.change_make_var! "LDFLAGS", "-L. -L./external/stage/lib -lboost_regex -lboost_system -lboost_filesystem -lboost_program_options -lc -lm -lcrypto -lboost_thread -lpthread"
    end
    system "make", "boost"
    system "make", "stream"
    bin.install "sdhash"
    man1.install Dir["man/*.1"]
  end

  test do
    system "#{bin}/sdhash"
  end
end
