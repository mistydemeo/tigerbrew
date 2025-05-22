class Libnice < Formula
  desc "GLib ICE implementation"
  homepage "http://nice.freedesktop.org/wiki/"
  url "http://nice.freedesktop.org/releases/libnice-0.1.7.tar.gz"
  sha256 "4ed165aa2203136dce548c7cef735d8becf5d9869793f96b99dcbbaa9acf78d8"


  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "gstreamer"

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
    ]

    system "./configure",  *args
    system "make", "install"
  end
end
