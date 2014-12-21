require "formula"

class Fish < Formula
  homepage "http://fishshell.com"
  url "https://github.com/fish-shell/fish-shell/releases/download/2.1.1/fish-2.1.1.tar.gz"
  sha1 "8f97f39b92ea7dfef1f464b18e304045bf37546d"

  bottle do
    sha1 "f03a733864d88f331cc6e89de4108c1e9c7f21ea" => :tiger_altivec
    sha1 "982078f3981f1685d077d3ee76a99b102b730b63" => :leopard_g3
    sha1 "6f53c19d3fa7c59cb5c401c90f535664a350b682" => :leopard_altivec
  end

  head do
    url "https://github.com/fish-shell/fish-shell.git", :shallow => false

    depends_on "autoconf" => :build
    # Indeed, the head build always builds documentation
    depends_on "doxygen" => :build
  end

  skip_clean "share/doc"

  def install
    if build.head?
      ENV['GIT_DIR'] = cached_download/'.git'
      system "autoconf"
    end
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
