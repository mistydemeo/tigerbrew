class Fish < Formula
  desc "User-friendly command-line shell for UNIX-like operating systems"
  homepage "http://fishshell.com"
  url "http://fishshell.com/files/2.2.0/fish-2.2.0.tar.gz"
  sha256 "a76339fd14ce2ec229283c53e805faac48c3e99d9e3ede9d82c0554acfc7b77a"

  bottle do
    sha256 "1a9a75647ab672132d4ea6b385a09461041f47a91a3719a82494467eaeceab97" => :tiger_altivec
    sha256 "e0ba430b35df479e52c0d33b6900cbfe55bf2779e7ab22c3e226db05e53f9410" => :leopard_g3
    sha256 "326cea656c8cadf59f2202293334c17d38dfb52ea21388f5fa2b44a6cd8cc46e" => :leopard_altivec
  end

  head do
    url "https://github.com/fish-shell/fish-shell.git", :shallow => false

    depends_on "autoconf" => :build
    depends_on "doxygen" => :build
  end

  def install
    system "autoconf" if build.head?
    # In Homebrew's 'superenv' sed's path will be incompatible, so
    # the correct path is passed into configure here.
    system "./configure", "--prefix=#{prefix}", "SED=/usr/bin/sed"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    You will need to add:
      #{HOMEBREW_PREFIX}/bin/fish
    to /etc/shells. Run:
      chsh -s #{HOMEBREW_PREFIX}/bin/fish
    to make fish your default shell.

    If you are upgrading from an older version of fish, you should now run:
      killall fishd
    to terminate the outdated fish daemon.
    EOS
  end

  test do
    system "#{bin}/fish", "-c", "echo"
  end
end
