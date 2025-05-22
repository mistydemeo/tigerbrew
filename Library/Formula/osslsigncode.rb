class Osslsigncode < Formula
  desc "Authenticode signing of PE(EXE/SYS/DLL/etc), CAB and MSI files"
  homepage "https://sourceforge.net/projects/osslsigncode/"
  url "https://downloads.sourceforge.net/project/osslsigncode/osslsigncode/osslsigncode-1.7.1.tar.gz"
  sha256 "f9a8cdb38b9c309326764ebc937cba1523a3a751a7ab05df3ecc99d18ae466c9"


  depends_on "pkg-config" => :build
  depends_on "autoconf" => :build
  depends_on "openssl"
  depends_on "libgsf" => :optional

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end
end
