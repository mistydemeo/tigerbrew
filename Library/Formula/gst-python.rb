class GstPython < Formula
  desc "GStreamer Python overrides for gobject-introspection-based pygst bindings"
  homepage "http://gstreamer.freedesktop.org/modules/gst-python.html"
  url "http://gstreamer.freedesktop.org/src/gst-python/gst-python-1.6.0.tar.xz"
  sha256 "60dbc7f5ac2b6655ed4a7ed2cee63ee5a525d37cb16eaa6b9df7d7dfe4e9605f"


  depends_on "gst-plugins-base"
  depends_on "pygobject3"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "gst-inspect-1.0", "python"
  end
end
