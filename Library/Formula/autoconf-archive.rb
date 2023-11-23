class AutoconfArchive < Formula
  desc "Collection of over 500 reusable autoconf macros"
  homepage "https://savannah.gnu.org/projects/autoconf-archive/"
  url "http://ftpmirror.gnu.org/autoconf-archive/autoconf-archive-2023.02.20.tar.xz"
  mirror "https://ftp.gnu.org/gnu/autoconf-archive/autoconf-archive-2023.02.20.tar.xz"
  sha256 "71d4048479ae28f1f5794619c3d72df9c01df49b1c628ef85fde37596dc31a33"

  bottle do
    cellar :any_skip_relocation
    sha256 "85eb453571547a14341cf7d53cfe8361db15969e974c9ad5cc2f14c1c2447cbc" => :tiger_altivec
  end

  # autoconf-archive is useless without autoconf
  depends_on "autoconf" => :run

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.m4").write <<-EOS.undent
      AC_INIT(myconfig, version-0.1)
      AC_MSG_NOTICE([Hello, world.])

      AC_CONFIG_MACRO_DIR([#{share}/aclocal])

      # https://www.gnu.org/software/autoconf-archive/ax_prog_cc_for_build.html
      AX_PROG_CC_FOR_BUILD
    EOS

    system "#{Formula["autoconf"].bin}/autoconf", "-o", testpath/"test", "test.m4"
  end
end
