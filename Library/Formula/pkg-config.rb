class PkgConfig < Formula
  desc "Manage compile and link flags for libraries"
  homepage "https://freedesktop.org/wiki/Software/pkg-config/"
  url "https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz"
  mirror "https://fossies.org/linux/misc/pkg-config-0.29.2.tar.gz"
  sha256 "6fc69c01688c9458a57eb9a1664c9aba372ccda420a02bf4429fe610e7e7d591"

  bottle do
    sha256 "1b438cc6b776c001c6a45b94f12861a3a5a98fc4ea2ee6069a6a011051188aff" => :tiger_altivec
    sha256 "050112af9584144b2f6aff3a17637b815f4196f0001820352e3ffba0ecf661ba" => :tiger_g3
  end

  option "with-tests", "Build and run the test suite"

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
    system "make", "check" if build.with?("tests") || build.bottle?
    system "make", "install"
  end

  test do
    system "#{bin}/pkg-config", "--libs", "openssl"
  end
end
