class Lftp < Formula
  desc "Sophisticated file transfer program"
  homepage "http://lftp.yar.ru/"
  url "http://lftp.yar.ru/ftp/lftp-4.6.4.tar.xz"
  sha256 "1e7cb674c83ace48172263f86847ed04bb6ab2f24116b11a8505f70a15e8805c"


  depends_on "pkg-config" => :build
  depends_on "readline"
  depends_on "openssl"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-openssl=#{Formula["openssl"].opt_prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/lftp", "-c", "open ftp://mirrors.kernel.org; ls"
  end
end
