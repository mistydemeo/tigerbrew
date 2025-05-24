class Dnstracer < Formula
  desc "Trace a chain of DNS servers to the source"
  homepage "http://www.mavetju.org/unix/dnstracer.php"
  url "http://www.mavetju.org/download/dnstracer-1.9.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/d/dnstracer/dnstracer_1.9.orig.tar.gz"
  sha256 "2ebc08af9693ba2d9fa0628416f2d8319ca1627e41d64553875d605b352afe9c"


  def install
    ENV.append "LDFLAGS", "-lresolv"

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end

  test do
    system "#{bin}/dnstracer", "brew.sh"
  end
end
