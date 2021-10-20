class Gdbm < Formula
  desc "GNU database manager"
  homepage "https://www.gnu.org/software/gdbm/"
  url "http://ftpmirror.gnu.org/gdbm/gdbm-1.11.tar.gz"
  mirror "https://ftp.gnu.org/gnu/gdbm/gdbm-1.11.tar.gz"
  sha256 "8d912f44f05d0b15a4a5d96a76f852e905d051bb88022fcdfd98b43be093e3c3"

  bottle do
    cellar :any
    revision 3
    sha256 "85c1dd545b82601a184a20ae048d1d8157226e9882f78f2e6314b52ae14be8ec" => :tiger_g4e
    sha256 "daac2b17e1515aab9e4a0465b3bf58f674d8232baeae232f4220d1add0d65443" => :leopard_g4e
  end

  option :universal
  option "with-libgdbm-compat", "Build libgdbm_compat, a compatibility layer which provides UNIX-like dbm and ndbm interfaces."

  def install
    ENV.universal_binary if build.universal?

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
    ]

    args << "--enable-libgdbm-compat" if build.with? "libgdbm-compat"

    system "./configure", *args
    system "make", "install"
  end

  test do
    pipe_output("#{bin}/gdbmtool --norc --newdb test", "store 1 2\nquit\n")
    assert File.exist?("test")
    assert_match /2/, pipe_output("#{bin}/gdbmtool --norc test", "fetch 1\nquit\n")
  end
end
