class Libssh2 < Formula
  desc "C library implementing the SSH2 protocol"
  homepage "http://www.libssh2.org/"
  url "https://libssh2.org/download/libssh2-1.8.0.tar.gz"
  sha256 "39f34e2f6835f4b992cafe8625073a88e5a28ba78f83e8099610a7b3af4676d4"

  option "with-libressl", "build with LibreSSL instead of OpenSSL"

  head do
    url "https://github.com/libssh2/libssh2.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  bottle do
    sha256 "4a1e39137bc9461d779a7a84626354928788aeb0650fb0fed75e0fbecb95c0cd" => :sierra
    sha256 "d6693c1417f0deb8f1b0c6a7c338491a7f60f2cc516675186e572329c1fcaa6c" => :el_capitan
    sha256 "f7fab0024a104c43a3139b0e70cbc04606c20409b36ffb6deebb326c168c4547" => :yosemite
  end

  depends_on "openssl" => :recommended
  depends_on "libressl" => :optional

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-examples-build
      --with-openssl
      --with-libz
    ]

    if build.with? "libressl"
      args << "--with-libssl-prefix=#{Formula["libressl"].opt_prefix}"
    else
      args << "--with-libssl-prefix=#{Formula["openssl"].opt_prefix}"
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
