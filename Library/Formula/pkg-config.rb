class PkgConfig < Formula
  homepage "https://wiki.freedesktop.org/www/Software/pkg-config/"
  url "http://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz"
  mirror "https://fossies.org/linux/misc/pkg-config-0.28.tar.gz"
  sha256 "6b6eb31c6ec4421174578652c7e141fdaae2dabad1021f420d8713206ac1f845"

  bottle do
  end

  def install
    pc_path = %W[
      #{HOMEBREW_PREFIX}/lib/pkgconfig
      #{HOMEBREW_PREFIX}/share/pkgconfig
      /usr/local/lib/pkgconfig
      /usr/lib/pkgconfig
      #{HOMEBREW_LIBRARY}/ENV/pkgconfig/#{MacOS.version}
    ].uniq.join(File::PATH_SEPARATOR)

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--disable-host-tool",
                          "--with-internal-glib",
                          "--with-pc-path=#{pc_path}"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    system "#{bin}/pkg-config", "--libs", "openssl"
  end
end
