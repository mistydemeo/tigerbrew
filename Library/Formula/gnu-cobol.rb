class GnuCobol < Formula
  desc "Implements much of the COBOL 85 and COBOL 2002 standards"
  homepage "http://www.opencobol.org/"
  url "https://prdownloads.sourceforge.net/project/gnucobol/gnucobol/3.2/gnucobol-3.2.tar.xz"
  sha256 "3bb48af46ced4779facf41fdc2ee60e4ccb86eaa99d010b36685315df39c2ee2"

  bottle do
    sha256 "49832dcbed74530fb9844e4ae9b75f8c87ac153f97a6f944fc3af4baab0470e5" => :tiger_altivec
  end

  depends_on "berkeley-db4"
  depends_on "gmp"
  depends_on "gettext"

  def install
    # Need unsetenv(3) to return int, not void
    ENV.append_to_cflags "-D__DARWIN_UNIX03" if MacOS.version == :tiger
    # both environment variables are needed to be set
    # the cobol compiler takes these variables for calling cc during its run
    # if the paths to gmp and bdb are not provided, the run of cobc fails
    gmp = Formula["gmp"]
    bdb = Formula["berkeley-db4"]
    ENV.append "CPPFLAGS", "-I#{gmp.opt_include} -I#{bdb.opt_include}"
    ENV.append "LDFLAGS", "-L#{gmp.opt_lib} -L#{bdb.opt_lib}"

    args = ["--prefix=#{prefix}", "--infodir=#{info}"]
    args << "--with-libiconv-prefix=/usr"
    args << "--with-libintl-prefix=/usr"

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"hello.cob").write <<-EOS
       IDENTIFICATION DIVISION.
       PROGRAM-ID. hello.
       PROCEDURE DIVISION.
       DISPLAY "Hello World!".
       STOP RUN.
    EOS
    system "#{bin}/cobc", "-x", testpath/"hello.cob"
    system testpath/"hello"
  end
end
