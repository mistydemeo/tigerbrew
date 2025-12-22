class GnuTar < Formula
  desc "GNU version of the tar archiving utility"
  homepage "https://www.gnu.org/software/tar/"
  url "http://ftpmirror.gnu.org/tar/tar-1.34.tar.xz"
  mirror "https://ftp.gnu.org/gnu/tar/tar-1.34.tar.xz"
  sha256 "63bebd26879c5e1eea4352f0d03c991f966aeb3ddeb3c7445c902568d5411d28"

  bottle do
    sha256 "f57c9b390419b477944bcbf7eaa18ae8bd2dc62007534679843e47cdde8143e1" => :tiger_altivec
    sha256 "19369ada94a817e68129bde73cb365cdb46ae6ff47e9e23e8e7d7b19ec0aed07" => :tiger_g3
  end

  option "with-default-names", "Do not prepend 'g' to the binary"

  def install
    args = ["--prefix=#{prefix}", "--mandir=#{man}"]
    args << "--program-prefix=g" if build.without? "default-names"

    system "./configure", *args
    system "make", "install"

    # Symlink the executable into libexec/gnubin as "tar"
    (libexec/"gnubin").install_symlink bin/"gtar" => "tar" if build.without? "default-names"
  end

  def caveats
    if build.without? "default-names" then <<-EOS.undent
      gnu-tar has been installed as "gtar".

      If you really need to use it as "tar", you can add a "gnubin" directory
      to your PATH from your bashrc like:

          PATH="#{opt_libexec}/gnubin:$PATH"
      EOS
    end
  end

  test do
    tar = build.with?("default-names") ? bin/"tar" : bin/"gtar"
    (testpath/"test").write("test")
    system tar, "-czvf", "test.tar.gz", "test"
    assert_match /test/, shell_output("#{tar} -xOzf test.tar.gz")
  end
end
