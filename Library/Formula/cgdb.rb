class Cgdb < Formula
  desc "Curses-based interface to the GNU Debugger"
  homepage "https://cgdb.github.io/"
  url "http://cgdb.me/files/cgdb-0.6.8.tar.gz"
  sha256 "be203e29be295097439ab67efe3dc8261f742c55ff3647718d67d52891f4cf41"
  revision 1


  head do
    url "https://github.com/cgdb/cgdb.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "help2man" => :build
  depends_on "readline"

  def install
    system "sh", "autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-readline=#{Formula["readline"].opt_prefix}"
    system "make", "install"
  end
end
