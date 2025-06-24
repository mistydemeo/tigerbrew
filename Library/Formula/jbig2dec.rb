class Jbig2dec < Formula
  desc "JBIG2 decoder and library (for monochrome documents)"
  homepage "http://ghostscript.com/jbig2dec.html"
  url "http://downloads.ghostscript.com/public/jbig2dec/jbig2dec-0.12.tar.gz"
  sha256 "bcc5f2cc75ee46e9a2c3c68d4a1b740280c772062579a5d0ceda24bee2e5ebf0"


  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "libtool" => :build
  depends_on "libpng" => :optional

  # http://bugs.ghostscript.com/show_bug.cgi?id=695890
  # Remove on next release.
  patch do
    # Original URL: http://git.ghostscript.com/?p=jbig2dec.git;a=commitdiff_plain;h=70c7f1967f43a94f9f0d6808d6ab5700a120d2fc
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/7dc28b82/jbig2dec/bug-695890.patch"
    sha256 "5239e4eb991f198d2ba30d08011c2887599b5cead9db8b1d3eacec4b8912c2d0"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-silent-rules
    ]

    args << "--without-libpng" if build.without? "libpng"

    system "autoreconf", "-fvi" # error: cannot find install-sh
    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{bin}/jbig2dec", "--version"
  end
end
