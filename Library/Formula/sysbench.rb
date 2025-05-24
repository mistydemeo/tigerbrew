class Sysbench < Formula
  desc "System performance benchmark tool"
  homepage "https://launchpad.net/sysbench"
  url "http://ftp.de.debian.org/debian/pool/main/s/sysbench/sysbench_0.4.12.orig.tar.gz"
  sha256 "83fa7464193e012c91254e595a89894d8e35b4a38324b52a5974777e3823ea9e"
  revision 1


  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "openssl"
  depends_on :mysql => :recommended
  depends_on :postgresql => :optional

  def install
    inreplace "configure.ac", "AC_PROG_LIBTOOL", "AC_PROG_RANLIB"
    system "./autogen.sh"

    args = ["--prefix=#{prefix}"]
    if build.with? "mysql"
      args << "--with-mysql"
    else
      args << "--without-mysql"
    end
    args << "--with-psql" if build.with? "postgresql"

    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{bin}/sysbench", "--test=cpu", "--cpu-max-prime=1", "run"
  end
end
