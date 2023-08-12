class Curl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.haxx.se/"
  url "https://curl.se/download/curl-8.2.1.tar.xz"
  mirror "http://mirror.sobukus.de/files/src/curl/curl-8.2.1.tar.xz"
  sha256 "dd322f6bd0a20e6cebdfd388f69e98c3d183bed792cf4713c8a7ef498cba4894"

  bottle do
    cellar :any
    sha256 "12acf882b1d17208fb42d0d2a06e98c2b619fce3ea53057567a7f63aca1b011b" => :tiger_altivec
  end

  keg_only :provided_by_osx

  option "with-rtmpdump", "Build with RTMP support"
  option "with-libssh2", "Build with scp and sftp support"
  option "with-c-ares", "Build with C-Ares async DNS support"
  option "with-gssapi", "Build with GSSAPI/Kerberos authentication support."
  option "with-libressl", "Build with LibreSSL instead of Secure Transport or OpenSSL"
  option "with-nghttp2", "Build with HTTP/2 support (requires OpenSSL or LibreSSL)"

  deprecated_option "with-rtmp" => "with-rtmpdump"
  deprecated_option "with-ssh" => "with-libssh2"
  deprecated_option "with-ares" => "with-c-ares"

  depends_on "zlib"

  # Build fix which can be removed in next release.
  # https://github.com/curl/curl/pull/11516
  patch do
    url "https://github.com/curl/curl/commit/8b7cbe9decc205b08ec8258eb184c89a33e3084b.patch"
    sha256 "71635c6e071fdce61f3176ed318edef9ec560d8afa7b62ac9492e2de7ebefeb4"
  end

  if (build.without?("libressl"))
    depends_on "openssl"
  end

  depends_on "pkg-config" => :build
  depends_on "rtmpdump" => :optional
  depends_on "libssh2" => :optional
  depends_on "c-ares" => :optional
  depends_on "libressl" => :optional
  depends_on "nghttp2" => :optional

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-zlib=#{Formula["zlib"].opt_prefix}
    ]

    # cURL has a new firm desire to find ssl with PKG_CONFIG_PATH instead of using
    # "--with-ssl" any more. "when possible, set the PKG_CONFIG_PATH environment
    # variable instead of using this option". Multi-SSL choice breaks w/o using it.
    if build.with? "libressl"
      ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["libressl"].opt_lib}/pkgconfig"
      args << "--with-ssl=#{Formula["libressl"].opt_prefix}"
      args << "--with-ca-bundle=#{etc}/libressl/cert.pem"
    else
      ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl"].opt_lib}/pkgconfig"
      args << "--with-ssl=#{Formula["openssl"].opt_prefix}"
      args << "--with-ca-bundle=#{etc}/openssl/cert.pem"
    end

    args << (build.with?("libssh2") ? "--with-libssh2" : "--without-libssh2")
    args << (build.with?("gssapi") ? "--with-gssapi" : "--without-gssapi")
    args << (build.with?("rtmpdump") ? "--with-librtmp" : "--without-librtmp")

    if build.with? "c-ares"
      args << "--enable-ares=#{Formula["c-ares"].opt_prefix}"
    else
      args << "--disable-ares"
    end

    # Tiger/Leopard ship with a horrendously outdated set of certs,
    # breaking any software that relies on curl, e.g. git
    args << "--with-ca-bundle=#{HOMEBREW_PREFIX}/share/ca-bundle.crt"

    system "./configure", *args
    system "make", "install"
    system "make", "install", "-C", "scripts"
    libexec.install "scripts/mk-ca-bundle.pl"
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = (testpath/"test.tar.gz")
    system "#{bin}/curl", "-L", stable.url, "-o", filename
    filename.verify_checksum stable.checksum

    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert File.exist?("test.pem")
    assert File.exist?("certdata.txt")
  end

  # Patch the configure script to avoid the autoreconf needed
  # after the patch we pulled in from github.
  patch :p0, :DATA
end
__END__
--- configure.orig	2023-08-11 14:31:54.000000000 +0100
+++ configure	2023-08-11 14:41:28.000000000 +0100
@@ -21707,10 +21707,10 @@
 int main (void)
 {
 
-#if (TARGET_OS_OSX)
+#if TARGET_OS_MAC && !(defined(TARGET_OS_IPHONE) && TARGET_OS_IPHONE)
       return 0;
 #else
-#error Not a macOS
+#error Not macOS
 #endif
 
  ;
