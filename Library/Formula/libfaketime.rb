class Libfaketime < Formula
  desc "Report faked system time to programs"
  homepage "http://www.code-wizards.com/projects/libfaketime"
  url "http://code-wizards.com/projects/libfaketime/libfaketime-0.9.5.tar.gz"
  sha256 "5e07678d440d632bef012068ca58825402da5ad25954513e785717cc539c213d"


  depends_on :macos => :lion

  fails_with :llvm do
    build 2336
    cause "No thread local storage support"
  end

  def install
    system "make", "-C", "src", "-f", "Makefile.OSX", "PREFIX=#{prefix}"
    bin.install "src/faketime"
    (lib/"faketime").install "src/libfaketime.1.dylib"
    man1.install "man/faketime.1"
  end
end
