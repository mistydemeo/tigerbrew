class Tig < Formula
  desc "Text interface for Git repositories"
  homepage "http://jonas.nitro.dk/tig/"
  url "http://jonas.nitro.dk/tig/releases/tig-2.1.1.tar.gz"
  sha256 "50c5179fd564b829b6b2cec087e66f10cf8799601de19350df0772ae77e4852f"
  head "https://github.com/jonas/tig.git"
  revision 1

  stable do
    url "http://jonas.nitro.dk/tig/releases/tig-2.1.1.tar.gz"
    sha256 "50c5179fd564b829b6b2cec087e66f10cf8799601de19350df0772ae77e4852f"

    # Merged in HEAD; remove in next stable release
    patch do
      url "https://github.com/jonas/tig/commit/91912eb97da4f6907015dab41ef9bba315730854.diff"
      sha256 "263e86b25f788eb158bdd667e112bc839debe9e3fe788cbc39cc9654b65b6c8a"
    end
  end


  head do
    url "https://github.com/jonas/tig.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  option "with-docs", "Build man pages using asciidoc and xmlto"

  if build.with? "docs"
    depends_on "asciidoc"
    depends_on "xmlto"
  end

  depends_on "readline" => :recommended

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--prefix=#{prefix}", "--sysconfdir=#{etc}"
    system "make", "install"
    system "make install-doc-man" if build.with? "docs"
    bash_completion.install "contrib/tig-completion.bash"
    zsh_completion.install "contrib/tig-completion.zsh" => "_tig"
    cp "#{bash_completion}/tig-completion.bash", zsh_completion
  end
end
