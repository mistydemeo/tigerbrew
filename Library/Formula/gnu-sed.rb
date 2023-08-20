class GnuSed < Formula
  desc "GNU implementation of the famous stream editor"
  homepage "https://www.gnu.org/software/sed/"
  url "http://ftpmirror.gnu.org/sed/sed-4.9.tar.xz"
  mirror "https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz"
  sha256 "6e226b732e1cd739464ad6862bd1a1aba42d7982922da7a53519631d24975181"

  bottle do
    sha256 "b22edf98fd285eecdb04ab8dfc92d9109f082d378f3e0b81c31143f410808ff0" => :tiger_altivec
  end

  conflicts_with "ssed", :because => "both install share/info/sed.info"

  deprecated_option "default-names" => "with-default-names"

  option "with-default-names", "Do not prepend 'g' to the binary"

  def install
    args = ["--prefix=#{prefix}", "--disable-dependency-tracking"]
    args << "--program-prefix=g" if build.without? "default-names"

    system "./configure", *args
    system "make", "install"

    (libexec/"gnubin").install_symlink bin/"gsed" =>"sed"
    (libexec/"gnuman/man1").install_symlink man1/"gsed.1" => "sed.1"
  end

  def caveats; <<-EOS.undent
    The command has been installed with the prefix "g".
    If you do not want the prefix, install using the "with-default-names" option.

    If you need to use these commands with their normal names, you
    can add a "gnubin" directory to your PATH from your bashrc like:

        PATH="#{opt_libexec}/gnubin:$PATH"

    Additionally, you can access their man pages with normal names if you add
    the "gnuman" directory to your MANPATH from your bashrc as well:

        MANPATH="#{opt_libexec}/gnuman:$MANPATH"

    EOS
  end

  test do
    system "#{bin}/gsed", "--version"
  end
end
