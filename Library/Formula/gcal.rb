class Gcal < Formula
  desc "Gcal is a program for calculating and printing calendars"
  homepage "https://www.gnu.org/software/gcal/"
  url "http://ftpmirror.gnu.org/gcal/gcal-4.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gcal/gcal-4.tar.xz"
  sha256 "59c5c876b12ec70649d90e2ce76afbe2f4ed93503d49ec39e5c575b3aef8ff6e"


  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make", "install"
  end

  test do
    date = shell_output("date +%Y")
    assert_match date, shell_output("#{bin}/gcal")
  end
end
