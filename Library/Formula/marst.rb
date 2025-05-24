class Marst < Formula
  desc "Algol-to-C translator"
  homepage "https://www.gnu.org/software/marst"
  url "http://ftpmirror.gnu.org/marst/marst-2.7.tar.gz"
  sha256 "3ee7b9d1cbe3cd9fb5f622717da7bb5506f1a6da3b30f812e2384b87bce4da50"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"hello.alg").write('begin outstring(1, "Hello, world!\n") end')
    system "#{bin}/marst -o hello.c hello.alg"
    system "#{ENV.cc} hello.c -lalgol -lm -o hello"
    system "./hello"
  end
end
