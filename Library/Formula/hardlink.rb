class Hardlink < Formula
  desc "Replace file copies using hardlinks"
  homepage "http://jak-linux.org/projects/hardlink/"
  url "http://jak-linux.org/projects/hardlink/hardlink_0.3.0.tar.xz"
  sha256 "e8c93dfcb24aeb44a75281ed73757cb862cc63b225d565db1c270af9dbb7300f"


  depends_on "pkg-config" => :build
  depends_on "gnu-getopt"
  depends_on "pcre"

  def install
    system "make", "PREFIX=#{prefix}", "MANDIR=#{man}", "BINDIR=#{bin}", "install"
  end

  test do
    system "#{bin}/hardlink", "--help"
  end
end
