class Libcue < Formula
  desc "Cue sheet parser library for C"
  homepage "http://sourceforge.net/projects/libcue/"
  url "http://pkgs.fedoraproject.org/repo/pkgs/libcue/libcue-1.4.0.tar.bz2/5f5045f00e6ac92d9a057fe5b0982c69/libcue-1.4.0.tar.bz2"
  sha256 "8b7276ec2a2b3918cbc59a3cc03c68dc0775965cc20e4b88757b852ff369729e"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
