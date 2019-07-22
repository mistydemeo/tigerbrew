class Tig < Formula
  desc "Text interface for Git repositories"
  homepage "http://jonas.nitro.dk/tig/"
  url "http://jonas.nitro.dk/tig/releases/tig-2.2.tar.gz"
  sha256 "8f5213d3abb45ca9a79810b8d2a2a12d941112bc4682bcfa91f34db74942754c"
  head "https://github.com/jonas/tig.git"
  revision 1

  stable do
    url "http://jonas.nitro.dk/tig/releases/tig-2.2.tar.gz"
    sha256 "8f5213d3abb45ca9a79810b8d2a2a12d941112bc4682bcfa91f34db74942754c"
  end

  bottle do
    cellar :any
    revision 1
    sha256 "e468112c6040d14397fa6976911345f691b20564166a6d116793f89e586245cf" => :el_capitan
    sha256 "f03fc214aa0b8f286a0e015ec447b342450e967abcb2ffad81c2211a2052dfbc" => :yosemite
    sha256 "b6996765930e0d2e17a17eaebc57fe6ba747db7a875469ca11bc782f1a344863" => :mavericks
    sha256 "d8fb10c0fd9ddbad7ef40cbddf2117b0552b6c4db64d5d6b9917bff6bdec358e" => :mountain_lion
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
