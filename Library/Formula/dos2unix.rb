class Dos2unix < Formula
  desc "Convert text between DOS, UNIX, and Mac formats"
  homepage "http://waterlan.home.xs4all.nl/dos2unix.html"
  url "https://waterlan.home.xs4all.nl/dos2unix/dos2unix-7.5.0.tar.gz"
  mirror "https://prdownloads.sourceforge.net/project/dos2unix/dos2unix/7.5.0/dos2unix-7.5.0.tar.gz"
  sha256 "7a3b01d01e214d62c2b3e04c3a92e0ddc728a385566e4c0356efa66fd6eb95af"

  devel do
    url "https://waterlan.home.xs4all.nl/dos2unix/dos2unix-7.5.1-beta1.tar.gz"
    sha256 "2db1db62169cf4cc7b8b24a61784f6a482af8d87f8cc620b7c3d697811baf73e"
  end

  bottle do
    sha256 "2110325f87260f0c2abc3fd31750b1330a828994fbd92e2de62c5bf06af415e6" => :tiger_altivec
  end

  option "with-gettext", "Build with Native Language Support"

  depends_on "gettext" => :optional

  def install
    args = %W[
      prefix=#{prefix}
      CC=#{ENV.cc}
      CPP=#{ENV.cc}
      CFLAGS=#{ENV.cflags}
      install
    ]

    if build.without? "gettext"
      args << "ENABLE_NLS="
    else
      gettext = Formula["gettext"]
      args << "CFLAGS_OS=-I#{gettext.include}"
      args << "LDFLAGS_EXTRA=-L#{gettext.lib} -lintl"
    end

    system "make", *args
  end

  test do
    # write a file with lf
    path = testpath/"test.txt"
    path.write "foo\nbar\n"

    # unix2mac: convert lf to cr
    system "#{bin}/unix2mac", path
    assert_equal "foo\rbar\r", path.read

    # mac2unix: convert cr to lf
    system "#{bin}/mac2unix", path
    assert_equal "foo\nbar\n", path.read

    # unix2dos: convert lf to cr+lf
    system "#{bin}/unix2dos", path
    assert_equal "foo\r\nbar\r\n", path.read

    # dos2unix: convert cr+lf to lf
    system "#{bin}/dos2unix", path
    assert_equal "foo\nbar\n", path.read
  end
end
