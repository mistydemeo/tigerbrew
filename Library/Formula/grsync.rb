class Grsync < Formula
  desc "GUI for rsync"
  homepage "http://www.opbyte.it/grsync/"
  url "https://downloads.sourceforge.net/project/grsync/grsync-1.2.5.tar.gz"
  sha256 "4f1443154f7c85ca7b0e93d5fea438e2709776005e7cfc97da89f4899b1c12e5"
  revision 1


  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "gettext"
  depends_on "gtk+"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-unity",
                          "--prefix=#{prefix}"

    system "make", "install"
  end

  test do
    # running the executable always produces the GUI, which is undesirable for the test
    # so we'll just check if the executable exists
    assert (bin/"grsync").exist?
  end
end
