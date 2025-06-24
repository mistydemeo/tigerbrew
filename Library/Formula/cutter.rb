class Cutter < Formula
  desc "Unit Testing Framework for C and C++"
  homepage "http://cutter.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/cutter/cutter/1.2.5/cutter-1.2.5.tar.gz"
  sha256 "e53613445e8fe20173a656db5a70a7eb0c4586be1d9f33dc93e2eddd2f646b20"
  head "https://github.com/clear-code/cutter.git"


  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "glib"
  depends_on "gettext"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-glibtest",
                          "--disable-goffice",
                          "--disable-gstreamer",
                          "--disable-libsoup"
    system "make"
    system "make", "install"
  end

  test do
    touch "1.txt"
    touch "2.txt"
    system bin/"cut-diff", "1.txt", "2.txt"
  end
end
