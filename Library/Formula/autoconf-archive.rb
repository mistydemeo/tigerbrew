class AutoconfArchive < Formula
  desc "Collection of over 500 reusable autoconf macros"
  homepage "https://savannah.gnu.org/projects/autoconf-archive/"
  url "http://ftpmirror.gnu.org/autoconf-archive/autoconf-archive-2024.10.16.tar.xz"
  mirror "https://ftp.gnu.org/gnu/autoconf-archive/autoconf-archive-2024.10.16.tar.xz"
  sha256 "7bcd5d001916f3a50ed7436f4f700e3d2b1bade3ed803219c592d62502a57363"

  bottle do
    cellar :any_skip_relocation
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
