class Npth < Formula
  desc "New GNU portable threads library"
  homepage "https://gnupg.org/index.html"
  url "https://gnupg.org/ftp/gcrypt/npth/npth-1.8.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/npth/npth-1.8.tar.bz2"
  sha256 "8bd24b4f23a3065d6e5b26e98aba9ce783ea4fd781069c1b35d149694e90ca3e"

  bottle do
    sha256 "53f5237df4b2749f5e08c23f379702ab84393a0f1f232d6086cec2b19e5a6e15" => :tiger_altivec
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--enable-install-npth-config",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/npth-config", "--version"
  end
end
