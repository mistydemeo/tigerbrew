class Gettext < Formula
  desc "GNU internationalization (i18n) and localization (l10n) library"
  homepage "https://www.gnu.org/software/gettext/"
  url "http://ftpmirror.gnu.org/gettext/gettext-0.19.5.1.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gettext/gettext-0.19.5.1.tar.xz"
  sha256 "66da00dc2c810d733b1f55a2a4af5cb669e2ee4259937d50a51d5614cdad323d"

  bottle do
    sha256 "b728d58d0da4529db302b6ab0dbdd3dd263a1257faa0962a518f20fb1e06a7e8" => :leopard_g3
    sha256 "aab7a6eed9fc34a712d1acc46155e3c307ad692cc2e070a51bfc5412454273d9" => :leopard_altivec
  end

  keg_only :shadowed_by_osx, "OS X provides the BSD gettext library and some software gets confused if both are in the library path."

  option :universal
  option 'with-examples', 'Keep example files'

  def patches
    unless build.include? 'with-examples'
      # Use a MacPorts patch to disable building examples at all,
      # rather than build them and remove them afterwards.
      {:p0 => ['https://trac.macports.org/export/102008/trunk/dports/devel/gettext/files/patch-gettext-tools-Makefile.in']}
    end
  end

  def install
    ENV.libxml2
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--disable-debug",
                          "--prefix=#{prefix}",
                          "--with-included-gettext",
                          "--with-included-glib",
                          "--with-included-libcroco",
                          "--with-included-libunistring",
                          "--with-emacs",
                          "--disable-java",
                          "--disable-csharp",
                          # Don't use VCS systems to create these archives
                          "--without-git",
                          "--without-cvs",
                          "--without-xz"
    system "make"
    ENV.deparallelize # install doesn't support multiple make jobs
    system "make", "install"
  end

  test do
    system "#{bin}/gettext", "test"
  end
end
