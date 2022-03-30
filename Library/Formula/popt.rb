class Popt < Formula
  desc "Library like getopt(3) with a number of enhancements"
  
  homepage "https://github.com/rpm-software-management/popt"
  url "http://ftp.rpm.org/popt/releases/popt-1.x/popt-1.18.tar.gz"
  mirror "https://ftp.osuosl.org/pub/rpm/popt/releases/popt-1.x/popt-1.18.tar.gz"
  mirror "https://fossies.org/linux/misc/popt-1.18.tar.gz"
  
  sha256 "5159bc03a20b28ce363aa96765f37df99ea4d8850b1ece17d1e6ad5c24fdc5d1"
  option :universal

  
  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
