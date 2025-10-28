class Gpatch < Formula
  desc "Apply a diff file to an original"
  homepage "https://savannah.gnu.org/projects/patch/"
  url "https://ftp.gnu.org/gnu/patch/patch-2.7.6.tar.xz"
  mirror "https://ftpmirror.gnu.org/patch/patch-2.7.6.tar.xz"
  sha256 "ac610bda97abe0d9f6b7c963255a11dcb196c25e337c61f94e4778d632f1d8fd"
  license "GPL-3.0-or-later"

  bottle do
    sha256 "be2c7778681f69650654614191a134d075ec98bbf868605c6d40147038dc69d2" => :tiger_altivec
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--program-prefix=g" 
    system "make", "install"

    # Symlink the executable into libexec/gnubin as "patch"
    (libexec/"gnubin").install_symlink bin/"gpatch" => "patch"
    (libexec/"gnuman/man1").install_symlink man1/"gpatch.1" => "patch.1"
    (libexec/"gnubin").install_symlink "../gnuman" => "man"
  end

  def caveats
    <<~EOS
      GNU "patch" has been installed as "gpatch".
      If you need to use it as "patch", you can add a "gnubin" directory
      to your PATH from your bashrc like:

          PATH="#{opt_libexec}/gnubin:$PATH"
    EOS
  end

  test do
    testfile = testpath/"test"
    testfile.write "homebrew\n"
    patch = <<~EOS
      1c1
      < homebrew
      ---
      > hello
    EOS
    pipe_output("#{bin}/gpatch #{testfile}", patch)
    assert_equal "hello", testfile.read.chomp
  end
end
