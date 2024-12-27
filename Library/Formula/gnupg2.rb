class Gnupg2 < Formula
  desc "GNU Privacy Guard: a free PGP replacement"
  homepage "https://www.gnupg.org/"
  url "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.4.7.tar.bz2"
  mirror "ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-2.4.7.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnupg/gnupg-2.4.7.tar.bz2"
  sha256 "7b24706e4da7e0e3b06ca068231027401f238102c41c909631349dcc3b85eb46"
  license "GPL-3.0-or-later"

  bottle do
  end

  depends_on "pkg-config" => :build
  depends_on "libgpg-error"
  depends_on "libgcrypt"
  depends_on "libksba"
  depends_on "libassuan"
  depends_on "pinentry"
  depends_on "npth"
  depends_on "libusb-compat" => :recommended
  depends_on "readline" => :recommended
  depends_on "bzip2"
  depends_on "gettext"
  depends_on "libiconv"
  depends_on "sqlite"
  depends_on "zlib"

  def install
    # Adjust package name to fit our scheme of packaging both gnupg 1.x and
    # 2.x, and adjust tests to fit this scheme
    inreplace "configure" do |s|
      s.gsub! "PACKAGE_NAME='gnupg'", "PACKAGE_NAME='gnupg2'"
      s.gsub! "PACKAGE_TARNAME='gnupg'", "PACKAGE_TARNAME='gnupg2'"
    end
    # sysutils.c:1201: error: void value not ignored as it ought to be
    ENV.append_to_cflags "-D__DARWIN_UNIX03" if MacOS.version == :tiger

    (var/"run").mkpath

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sbindir=#{bin}
      --with-pinentry-pgm=#{Formula["pinentry"].opt_bin}/pinentry
      --disable-ldap
    ]

    if build.with? "readline"
      args << "--with-readline=#{Formula["readline"].opt_prefix}"
    end

    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"

  end

  test do
    system "#{bin}/gpgconf"
  end
end
