class UcspiTools < Formula
  desc "Various tools to handle UCSPI connections"
  homepage "https://github.com/younix/ucspi/blob/master/README.md"
  url "https://github.com/younix/ucspi/archive/v1.2.tar.gz"
  sha256 "38cd0ae9113324602a600a6234d60ec9c3a8c13c8591e9b730f91ffb77e5412a"
  revision 5


  depends_on "pkg-config" => :build
  depends_on "ucspi-tcp"
  depends_on "libressl"

  # LibreSSL renamed a function between the 2.1.3 and 2.1.4 release which ucspi uses.
  # https://github.com/younix/ucspi/issues/2
  # http://www.freshbsd.org/commit/openbsd/2b22762d1139c74c743195f46b41fea0b9459ecd
  patch do
    url "https://github.com/younix/ucspi/pull/3.diff"
    sha256 "932aa6fcde21dc4eb3ad4474a6cd5f413f4da076b1de1491360a60584e0e514e"
  end

  def install
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    out = shell_output("#{bin}/tlsc 2>&1", 1)
    assert_equal "tlsc [-hCH] [-c cert_file] [-f ca_file] [-p ca_path] program [args...]\n", out
  end
end
