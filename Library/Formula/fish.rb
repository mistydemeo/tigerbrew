require 'formula'

class Fish < Formula
  homepage 'http://fishshell.com'
  url 'http://fishshell.com/files/2.1.0/fish-2.1.0.tar.gz'
  sha1 'b1764cba540055cb8e2a96a7ea4c844b04a32522'

  head do
    url 'https://github.com/fish-shell/fish-shell.git'

    depends_on :autoconf
    # Indeed, the head build always builds documentation
    depends_on 'doxygen' => :build
  end

  bottle do
    sha1 "d75e3e0f0ff294ca60281236a6d3c18746256515" => :tiger_g3
    sha1 "ac86ecc892592d98a7b005518c1e1c42653f412a" => :tiger_altivec
    sha1 "1212335fe762804fc342c3b967a55d3bee8d902b" => :leopard_g3
    sha1 "5ec405893b0c242b04bb6036bfa906b006bd285f" => :leopard_altivec
  end

  skip_clean 'share/doc'

  def install
    system "autoconf" if build.head?
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
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
