class Fish < Formula
  desc "User-friendly command-line shell for UNIX-like operating systems"
  homepage "http://fishshell.com"
  url "https://github.com/fish-shell/fish-shell/releases/download/3.0.0/fish-3.0.0.tar.gz"
  sha256 "ea9dd3614bb0346829ce7319437c6a93e3e1dfde3b7f6a469b543b0d2c68f2cf"

  bottle do
  end

  needs :cxx11
  depends_on "cmake" => :build
  # Apple ncurses (5.4) is 15+ years old and
  # has poor support for modern terminals
  depends_on "ncurses"
  depends_on "pcre2"

  def install
    # Necessary to get the standard signature of ttyname_r()
    ENV.append_to_cflags "-D__DARWIN_UNIX03" if MacOS.version < :leopard

    # In Homebrew's 'superenv' sed's path will be incompatible, so
    # the correct path is passed into configure here.
    args = %W[
      -DCMAKE_INSTALL_SYSCONFDIR=#{etc}
      -Dextra_functionsdir=#{HOMEBREW_PREFIX}/share/fish/vendor_functions.d
      -Dextra_completionsdir=#{HOMEBREW_PREFIX}/share/fish/vendor_completions.d
      -Dextra_confdir=#{HOMEBREW_PREFIX}/share/fish/vendor_conf.d
    ]
    args.concat(std_cmake_args)

    mkdir "build" do
      system "cmake", "-S", "..", *args
      system "make", "install"
    end
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
