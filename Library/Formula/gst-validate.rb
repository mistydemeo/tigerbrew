class GstValidate < Formula
  desc "Tools to validate GstElements from GStreamer"
  homepage "http://gstreamer.freedesktop.org/data/doc/gstreamer/head/gst-validate/html/"
  url "http://gstreamer.freedesktop.org/src/gst-validate/gst-validate-1.6.0.tar.xz"
  sha256 "3baef8c7b5363293c20314a30afd54629849fc597669991fdcf92303602dafee"


  head do
    url "git://anongit.freedesktop.org/gstreamer/gst-devtools"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "gobject-introspection"
  depends_on "gstreamer"
  depends_on "gst-plugins-base"

  def install
    inreplace "tools/gst-validate-launcher.in", "env python2", "env python"

    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
    ]

    if build.head?
      ENV["NOCONFIGURE"] = "yes"
      cd "validate" do
        system "./autogen.sh"
        system "./configure", *args
        system "make"
        system "make", "install"
      end
    else
      system "./configure", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    system "#{bin}/gst-validate-launcher", "--usage"
  end
end
