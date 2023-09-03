class Fish < Formula
  desc "User-friendly command-line shell for UNIX-like operating systems"
  homepage "http://fishshell.com"
  url "https://github.com/fish-shell/fish-shell/releases/download/2.7.1/fish-2.7.1.tar.gz"
  sha256 "e42bb19c7586356905a58578190be792df960fa81de35effb1ca5a5a981f0c5a"

  head do
    url "https://github.com/fish-shell/fish-shell.git", :shallow => false

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "doxygen" => :build
    depends_on "libtool" => :build
  end

  bottle do
    sha256 "931bbe0322164134e8de86f4be1adc3bfd5a7e8e85f12bed2fa1f8aa2d05ade9" => :tiger_g4e
    sha256 "5a74df5ca15c5b2ddb6b2556d2d7b06006556daa6d623fdf0ade3f9c377b4a50" => :leopard_g4e
  end

  needs :cxx11
  depends_on "pcre2"

  def install
    system "autoreconf", "--no-recursive" if build.head?
    # Necessary to get the standard signature of ttyname_r()
    ENV.append_to_cflags "-D__DARWIN_UNIX03" if MacOS.version < :leopard

    # In Homebrew's 'superenv' sed's path will be incompatible, so
    # the correct path is passed into configure here.
    args = %W[
      --prefix=#{prefix}
      --with-extra-functionsdir=#{HOMEBREW_PREFIX}/share/fish/vendor_functions.d
      --with-extra-completionsdir=#{HOMEBREW_PREFIX}/share/fish/vendor_completions.d
      --with-extra-confdir=#{HOMEBREW_PREFIX}/share/fish/vendor_conf.d
      SED=/usr/bin/sed
    ]
    system "./configure", *args
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    You will need to add:
      #{HOMEBREW_PREFIX}/bin/fish
    to /etc/shells.

    Then run:
      chsh -s #{HOMEBREW_PREFIX}/bin/fish
    to make fish your default shell.
    EOS
  end

  def post_install
    (pkgshare/"vendor_functions.d").mkpath
    (pkgshare/"vendor_completions.d").mkpath
    (pkgshare/"vendor_conf.d").mkpath
  end

  test do
    system "#{bin}/fish", "-c", "echo"
  end
end
