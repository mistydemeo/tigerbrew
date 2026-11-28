class Apachetop < Formula
  desc "Top-like display of Apache log"
  homepage "https://github.com/tessus/apachetop"
  url "https://github.com/tessus/apachetop/releases/download/0.18.4/apachetop-0.18.4.tar.gz"
  sha256 "34ee3ad380f1f7c055a96296420f15011b522781691137ea4e3a36f6bd195568"

  head "https://github.com/tessus/apachetop.git"

  def install
    args = [
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--disable-dependency-tracking"
    ]

    args << if MacOS.version <= :tiger then
      "--with-logfile=/var/log/httpd/access_log"
    else
      "--with-logfile=/var/log/apache2/access_log"
    end

    system "./configure", *args
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/apachetop -v")
    assert_match "ApacheTop #{version}", output
  end
end
