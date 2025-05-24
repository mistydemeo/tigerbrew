class PgpoolIi < Formula
  desc "PostgreSQL connection pool server"
  homepage "http://www.pgpool.net/mediawiki/index.php/Main_Page"
  url "http://www.pgpool.net/download.php?f=pgpool-II-3.4.2.tar.gz"
  sha256 "d031fea1313eaf84116f16bc6d0053c9432b04da160e5544ab6445c1f876c351"


  depends_on :postgresql

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system bin/"pg_md5", "--md5auth", "pool_passwd", "--config-file", etc/"pgpool.conf.sample"
  end
end
