class Primesieve < Formula
  desc "Optimized sieve of Eratosthenes implementation"
  homepage "http://primesieve.org/"
  url "https://dl.bintray.com/kimwalisch/primesieve/primesieve-5.4.2.tar.gz"
  sha256 "73abf4ff118e8d41ffaf687cf902b0b53a8bbc357bf4efa1798477d346f85cc8"


  def install
    system "./configure", "--disable-dependency-tracking", "--disable-silent-rules",
           "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/primesieve", "2", "1000", "--count=1", "-p2"
  end
end
