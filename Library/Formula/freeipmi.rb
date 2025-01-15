class Freeipmi < Formula
  desc "In-band and out-of-band IPMI (v1.5/2.0) software"
  homepage "https://www.gnu.org/software/freeipmi/"
  url "https://ftpmirror.gnu.org/freeipmi/freeipmi-1.6.14.tar.gz"
  mirror "https://ftp.gnu.org/gnu/freeipmi/freeipmi-1.6.14.tar.gz"
  sha256 "1a3dac5c76b7ccc4d4f86aa12b8ef9b212baef7489bf05e899b89abb7e14edb5"
  license "GPL-3.0-or-later"

  bottle do
    sha256 "0dda664db22f939b03563c3f0b6177d8740198fe5881a7dd1d29f91a21b5c171" => :tiger_altivec
  end

  depends_on "argp-standalone"
  depends_on "libgcrypt"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{sbin}/ipmi-fru", "--version"
  end
end
