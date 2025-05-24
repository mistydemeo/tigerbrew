class Dvorak7min < Formula
  desc "Dvorak (simplified keyboard layout) typing tutor"
  homepage "http://dvorak7min.sourcearchive.com/"
  url "http://ftp.de.debian.org/debian/pool/main/d/dvorak7min/dvorak7min_1.6.1+repack.orig.tar.gz"
  sha256 "4cdef8e4c8c74c28dacd185d1062bfa752a58447772627aded9ac0c87a3b8797"
  version "1.6.1"


  def install
    # Remove pre-built ELF binary first
    system "make", "clean"
    system "make"
    system "make", "INSTALL=#{bin}", "install"
  end
end
