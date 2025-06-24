class Lnav < Formula
  desc "Curses-based tool for viewing and analyzing log files"
  homepage "http://lnav.org"
  url "https://github.com/tstack/lnav/releases/download/v0.7.3/lnav-0.7.3.tar.gz"
  sha256 "7eb052a8dc60bef6c5f4a8e7135b7089b4413edbf156cc8bafce0557d3166df3"
  revision 1


  head do
    url "https://github.com/tstack/lnav.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "re2c" => :build
  end

  depends_on "readline"
  depends_on "pcre"

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-readline=#{Formula["readline"].opt_prefix}"
    system "make", "install"
  end
end
