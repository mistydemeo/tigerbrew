class DbusGlib < Formula
  desc "GLib bindings for the D-Bus message bus system"
  homepage "https://wiki.freedesktop.org/www/Software/DBusBindings/"
  url "http://dbus.freedesktop.org/releases/dbus-glib/dbus-glib-0.104.tar.gz"
  sha256 "bfc1f1a82bfc3ec3ecafe04d0e87bab7e999f50dce4f4a34d0b89caf6bd821f6"


  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "glib"
  depends_on "d-bus"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system bin/"dbus-binding-tool", "--help"
  end
end
