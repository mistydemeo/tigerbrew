class Libewf < Formula
  desc "Library for support of the Expert Witness Compression Format"
  homepage "https://github.com/libyal/libewf"
  url "https://github.com/libyal/libewf/releases/download/20230212/libewf-experimental-20230212.tar.gz"
  sha256 "d22eecbd962c3d7d646ccfba131fc3c07e6a07da37dc163b6ecbb1348db16101"

  bottle do
    sha256 "429b192b8eebbe45861e3aa333cb8bca58d80b38bd415cbae4a1eb7f2f38ef35" => :tiger_altivec
  end

  head do
    url "https://github.com/libyal/libewf.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "gettext" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "openssl"
  depends_on "zlib"

  def install
    if build.head?
      system "./synclibs.sh"
      system "./autogen.sh"
    end
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ewfinfo -V")
  end
end
