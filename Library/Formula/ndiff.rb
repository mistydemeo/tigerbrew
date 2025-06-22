class Ndiff < Formula
  desc "Virtual package provided by nmap"
  homepage "https://www.math.utah.edu/~beebe/software/ndiff/"
  url "ftp://ftp.math.utah.edu/pub/misc/ndiff-2.00.tar.gz"
  sha256 "f2bbd9a2c8ada7f4161b5e76ac5ebf9a2862cab099933167fe604b88f000ec2c"

  conflicts_with "nmap", :because => "both install `ndiff` binaries"

  def install
    ENV.j1
    # Install manually as the `install` make target is crufty
    system "./configure", "--prefix=.", "--mandir=."
    mkpath "bin"
    mkpath "man/man1"
    system "make", "install"
    bin.install "bin/ndiff"
    man1.install "man/man1/ndiff.1"
  end

  test do
    system "#{bin}/ndiff", "--help"
  end
end
