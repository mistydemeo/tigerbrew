class DfuUtil < Formula
  desc "USB programmer"
  homepage "http://dfu-util.sourceforge.net/"
  # Upstream moved, no releases yet, using debian mirror until then.
  # (see #34047 and #39181)
  url "https://prdownloads.sourceforge.net/project/dfu-util/dfu-util-0.11.tar.gz"
  sha256 "b4b53ba21a82ef7e3d4c47df2952adf5fa494f499b6b0b57c58c5d04ae8ff19e"

  bottle do
    cellar :any
  end

  head do
    url "git://git.code.sf.net/p/dfu-util/dfu-util"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "libusb"

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system bin/"dfu-util", "-V"
    system bin/"dfu-prefix", "-V"
    system bin/"dfu-suffix", "-V"
  end
end
