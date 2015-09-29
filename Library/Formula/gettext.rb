class Gettext < Formula
  desc "GNU internationalization (i18n) and localization (l10n) library"
  homepage "https://www.gnu.org/software/gettext/"
  url "http://ftpmirror.gnu.org/gettext/gettext-0.19.6.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gettext/gettext-0.19.6.tar.xz"
  sha256 "9b95816620fd1168cb4eeca0e9dc0ffd86e864fc668f76f5e37cc054d6982e51"

  bottle do
    sha256 "41a26cf4db47c63a8d1b93092dc45bb56a832701d11838277221fd934af4ed8a" => :tiger_altivec
    sha256 "5c7b69d10f0a5e330285d1806d10ce85f0a8e01eb727ba92bcdb815d2e08f6ca" => :leopard_g3
    sha256 "522195faf5f9c5cbd80ecfb7e6f72653a248cc893be53a931c2949645f48f51b" => :leopard_altivec
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
