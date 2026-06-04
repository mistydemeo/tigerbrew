class GnuSed < Formula
  desc "GNU implementation of the famous stream editor"
  homepage "https://www.gnu.org/software/sed/"
  url "https://ftpmirror.gnu.org/sed/sed-4.10.tar.xz"
  mirror "https://ftp.gnu.org/gnu/sed/sed-4.10.tar.xz"
  sha256 "b8e72182b2ec96a3574e2998c47b7aaa64cc20ce000d8e9ac313cc07cecf28c7"

  bottle do
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
    test_file = testpath/"test.txt"
    test_file.write "Hello world!"
    system bin/"gsed", "-i", "s/world/World/g", "test.txt"
    assert_match "Hello World!", test_file.read
    system opt_libexec/"gnubin/sed", "-i", "s/world/World/g", "test.txt"
    assert_match "Hello World!", test_file.read
  end
end
