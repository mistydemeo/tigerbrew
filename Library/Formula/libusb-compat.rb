class LibusbCompat < Formula
  desc "Library for USB device access"
  homepage "http://www.libusb.org/"
  url "https://downloads.sourceforge.net/project/libusb/libusb-compat-0.1/libusb-compat-0.1.8/libusb-compat-0.1.8.tar.bz2"
  sha256 "b692dcf674c070c8c0bee3c8230ce4ee5903f926d77dc8b968a4dd1b70f9b05c"

  bottle do
    cellar :any
    sha256 "996c8b94dafaa5a6a973871fcdfeda28168d882552734daf130984a6cc2d6dc6" => :tiger_altivec
  end

  option :universal

  depends_on "pkg-config" => :build
  depends_on "libusb"

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make", "install"
  end

  test do
    system "#{bin}/libusb-config", "--libs"
  end
end
