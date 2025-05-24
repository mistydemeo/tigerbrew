class SharedMimeInfo < Formula
  desc "Database of common MIME types"
  homepage "https://wiki.freedesktop.org/www/Software/shared-mime-info"
  url "http://freedesktop.org/~hadess/shared-mime-info-1.5.tar.xz"
  sha256 "d6412840eb265bf36e61fd7b6fc6bea21b0f58cb22bed16f2ccccdd54bea4180"


  head do
    url "http://anongit.freedesktop.org/git/xdg/shared-mime-info.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "intltool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "gettext"
  depends_on "glib"

  def install
    # Disable the post-install update-mimedb due to crash
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-update-mimedb
    ]
    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make", "install"
  end

  test do
    cp_r share/"mime", testpath
    system bin/"update-mime-database", testpath/"mime"
  end
end
