class PkgConfig < Formula
  desc "Manage compile and link flags for libraries"
  homepage "https://freedesktop.org/wiki/Software/pkg-config/"
  url "https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.1.tar.gz"
  mirror "https://fossies.org/linux/misc/pkg-config-0.29.1.tar.gz"
  sha256 "beb43c9e064555469bd4390dcfd8030b1536e0aa103f08d7abf7ae8cac0cb001"
  revision 2

  bottle do
    sha256 "89aa358bfdc95a5d0d84e2b5c2551ad47dbd30cad5e36058da5a9624fca58867" => :tiger_g4e
    sha256 "5c54354f79aae43008d449c26136e5355884383396f60b2b0d7fc51cfe3f8964" => :leopard_g4e
  end

  def install
    pc_path = %W[
      #{HOMEBREW_PREFIX}/lib/pkgconfig
      #{HOMEBREW_PREFIX}/share/pkgconfig
      /usr/local/lib/pkgconfig
      /usr/lib/pkgconfig
      #{HOMEBREW_LIBRARY}/ENV/pkgconfig/#{MacOS.version}
    ].uniq.join(File::PATH_SEPARATOR)

    ENV.append "LDFLAGS", "-framework Foundation -framework Cocoa"
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
