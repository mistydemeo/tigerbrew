class Autogen < Formula
  desc "Automated text file generator"
  homepage "http://autogen.sourceforge.net"
  url "http://ftpmirror.gnu.org/autogen/rel5.18.4/autogen-5.18.4.tar.xz"
  mirror "https://ftp.gnu.org/gnu/autogen/rel5.18.4/autogen-5.18.4.tar.xz"
  sha256 "7fbaff0c25035aee5b96913de2c83d9a5cc973b8dc08d6b7489ecbcfd72eb84b"


  depends_on "pkg-config" => :build
  depends_on "guile"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"

    # make and install must be separate steps for this formula
    system "make"
    system "make", "install"
  end

  test do
    system bin/"autogen", "-v"
  end
end
