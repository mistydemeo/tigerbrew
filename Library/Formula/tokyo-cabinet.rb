class TokyoCabinet < Formula
  desc "Lightweight database library"
  homepage "http://fallabs.com/tokyocabinet/"
  url "http://fallabs.com/tokyocabinet/tokyocabinet-1.4.48.tar.gz"
  mirror "http://ftp.de.debian.org/debian/pool/main/t/tokyocabinet/tokyocabinet_1.4.48.orig.tar.gz"
  sha256 "a003f47c39a91e22d76bc4fe68b9b3de0f38851b160bbb1ca07a4f6441de1f90"

  bottle do
    sha256 "71d978130f7d8b003337eebda4e0c87273385b8b462a92dfc374677b4dd458c9" => :tiger_altivec
  end

  def install
    # libtool is passed -w by gcc-4.0, and chokes on it
    ENV.enable_warnings if ENV.compiler == :gcc_4_0

    args = %W[--prefix=#{prefix}]

    system "./configure", *args
    system "make"
    system "make", "install"
  end
end
