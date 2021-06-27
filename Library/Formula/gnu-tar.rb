class GnuTar < Formula
  desc "GNU version of the tar archiving utility"
  homepage "https://www.gnu.org/software/tar/"
  url "http://ftpmirror.gnu.org/tar/tar-1.28.tar.gz"
  mirror "https://ftp.gnu.org/gnu/tar/tar-1.28.tar.gz"
  sha256 "6a6b65bac00a127a508533c604d5bf1a3d40f82707d56f20cefd38a05e8237de"

  option "with-default-names", "Do not prepend 'g' to the binary"

  bottle do
    revision 3
    sha256 "8e443b6faee8c4971ea5778b4327a6454b5719dc93ce4e4da501658c12d521fa" => :tiger_g4e
  end

  # Fix for xattrs bug causing build failures on OS X:
  # https://lists.gnu.org/archive/html/bug-tar/2014-08/msg00001.html
  patch do
    url "https://gist.githubusercontent.com/mistydemeo/10fbae8b8441359ba86d/raw/e5c183b72036821856f9e82b46fba6185e10e8b9/gnutar-configure-xattrs.patch"
    sha256 "f2e56bb8afd1c641a7e5b81e35fdbf36b6fb66434b1e35caa8b55196b30c3ad9"
  end

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
