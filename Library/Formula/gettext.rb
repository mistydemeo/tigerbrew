class Gettext < Formula
  desc "GNU internationalization (i18n) and localization (l10n) library"
  homepage "https://www.gnu.org/software/gettext/"
  url "https://ftpmirror.gnu.org/gettext/gettext-0.19.8.1.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gettext/gettext-0.19.8.1.tar.xz"
  sha256 "105556dbc5c3fbbc2aa0edb46d22d055748b6f5c7cd7a8d99f8e7eb84e938be4"

  bottle do
    sha256 "42c0a01f497f4d478ac42f886c395d55f4b4be2f326c235822d65bdfc1d05013" => :tiger_altivec
  end

  keg_only :shadowed_by_osx, "OS X provides the BSD gettext library and some software gets confused if both are in the library path."

  option :universal
  option 'with-examples', 'Keep example files'

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
                          "--with-lispdir=#{share}/emacs/site-lisp/gettext",
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
