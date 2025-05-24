class Hamlib < Formula
  desc "Ham radio control libraries"
  homepage "http://hamlib.sourceforge.net"
  url "http://pkgs.fedoraproject.org/repo/pkgs/hamlib/hamlib-1.2.15.3.tar.gz/3cad8987e995a00e5e9d360e2be0eb43/hamlib-1.2.15.3.tar.gz"
  sha256 "a2ca4549e4fd99d6e5600e354ebcb57502611aa63c6921c1b8a825289833f75e"


  depends_on "pkg-config" => :build
  depends_on "libtool" => :run
  depends_on "libusb-compat"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/rigctl", "-V"
  end
end
