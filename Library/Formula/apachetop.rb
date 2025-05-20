class Apachetop < Formula
  desc "Top-like display of Apache log"
  homepage "https://github.com/tessus/apachetop"
  url "https://github.com/tessus/apachetop/releases/download/0.23.2/apachetop-0.23.2.tar.gz"
  sha256 "f94a34180808c3edb24c1779f72363246dd4143a89f579ef2ac168a45b04443f"

  head "https://github.com/tessus/apachetop.git"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build
  depends_on "ncurses"
  depends_on "pcre2"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-logfile=/var/log/apache2/access_log"
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/apachetop -h 2>&1", 1)
    assert_match "ApacheTop v#{version}", output
  end
end
