class Slony < Formula
  desc "Master to multiple slaves replication system for PostgreSQL"
  homepage "http://slony.info/"
  url "http://main.slony.info/downloads/2.2/source/slony1-2.2.4.tar.bz2"
  mirror "https://mirrors.kernel.org/debian/pool/main/s/slony1-2/slony1-2_2.2.4.orig.tar.bz2"
  sha256 "846a878f50de520d151e7f76a66d9b9845e94beb8820727bf84ab522a73e65b5"


  depends_on :postgresql

  def install
    system "./configure", "--disable-debug",
                          "--with-pgconfigdir=#{Formula["postgresql"].opt_bin}",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system bin/"slon", "-v"
  end
end
