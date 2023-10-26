class Libssh2 < Formula
  desc "C library implementing the SSH2 protocol"
  homepage "http://www.libssh2.org/"
  url "https://libssh2.org/download/libssh2-1.11.0.tar.xz"
  sha256 "a488a22625296342ddae862de1d59633e6d446eff8417398e06674a49be3d7c2"
  revision 1

  bottle do
    cellar :any
    sha256 "199ff7918596f64fab5429e23f6bf6f6e3819563dd1c11031cd5aaae620224c7" => :tiger_altivec
  end

  option "with-libressl", "build with LibreSSL instead of OpenSSL"

  head do
    url "https://github.com/libssh2/libssh2.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "openssl3" => :recommended
  depends_on "libressl" => :optional
  depends_on "zlib"

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-examples-build
      --with-libz
      --with-libz-prefix=#{Formula["zlib"].opt_prefix}
     ]

    if build.with? "libressl"
      args << "--with-libssl-prefix=#{Formula["libressl"].opt_prefix}"
    else
      args << "--with-libssl-prefix=#{Formula["openssl3"].opt_prefix}"
    end

    system "./buildconf" if build.head?
    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <libssh2.h>

      int main(void)
      {
      libssh2_exit();
      return 0;
      }
    EOS

    system ENV.cc, "test.c", "-L#{lib}", "-lssh2", "-o", "test"
    system "./test"
  end
end
