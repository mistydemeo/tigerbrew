class Mtools < Formula
  desc "Tools for manipulating MSDOS files"
  homepage "https://www.gnu.org/software/mtools/"
  url "http://ftpmirror.gnu.org/mtools/mtools-4.0.43.tar.bz2"
  mirror "https://ftp.gnu.org/gnu/mtools/mtools-4.0.43.tar.bz2"
  sha256 "541e179665dc4e272b9602f2074243591a157da89cc47064da8c5829dbd2b339"

  bottle do
    sha256 "b947d6cf459d59fb692acb286fedc461858ec1e31622a06eb41bc3c06f46a021" => :tiger_altivec
  end

  conflicts_with "multimarkdown", :because => "both install `mmd` binaries"

  depends_on :x11 => :optional

  def install
    args = %W[
      LIBS=-liconv
      --disable-debug
      --prefix=#{prefix}
      --sysconfdir=#{etc}
    ]

    if build.with? "x11"
      args << "--with-x"
    else
      args << "--without-x"
    end

    system "./configure", *args
    system "make"
    ENV.deparallelize
    system "make", "install"
  end

  test do
    assert_match /#{version}/, shell_output("#{bin}/mtools --version")
  end
end
