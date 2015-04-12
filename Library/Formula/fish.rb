class Fish < Formula
  homepage "http://fishshell.com"
  url "http://fishshell.com/files/2.1.2/fish-2.1.2.tar.gz"
  sha1 "f7f8d8d26721833be3458b8113c74b747296ec0b"

  bottle do
  end

  head do
    url "https://github.com/fish-shell/fish-shell.git", :shallow => false

    depends_on "autoconf" => :build
    # Indeed, the head build always builds documentation
    depends_on "doxygen" => :build
  end

  skip_clean "share/doc"

  def install
    system "autoconf" if build.head?
    # In Homebrew's 'superenv' sed's path will be incompatible, so
    # the correct path is passed into configure here.
    system "./configure", "--prefix=#{prefix}", "SED=/usr/bin/sed"
    system "make", "install"
  end

  def post_install
    system "pkill fishd || true"
  end

  test do
    system "#{bin}/fish", "-c", "echo"
  end

  def caveats; <<-EOS.undent
    You will need to add:
      #{HOMEBREW_PREFIX}/bin/fish
    to /etc/shells. Run:
      chsh -s #{HOMEBREW_PREFIX}/bin/fish
    to make fish your default shell.
    EOS
  end
end
