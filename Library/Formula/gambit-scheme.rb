class GambitScheme < Formula
  desc "Complete, portable implementation of Scheme"
  homepage "http://gambitscheme.org"
  url "http://gambitscheme.org/latest/gambit-v4_9_5.tgz"
  sha256 "e28ef8db5f0e7b1159720c150053dcab8f7c4cae1f0e5c838944797073f8c1dc"

  bottle do
    sha256 "a9adffc0a71887460e7419c42732f5a6eb900f3ef74ccbe6bd634f37ab38e8d5" => :tiger_altivec
  end

  conflicts_with "scheme48", :because => "both install `scheme-r5rs` binaries"

  deprecated_option "enable-shared" => "with-shared"
  option "with-check", 'Execute "make check" before installing'
  option "with-shared", "Build Gambit Scheme runtime as shared library"
  option "with-single", "Compile each Scheme module as a single C function - Needs GCC >=5"
  option "with-openssl", "Build with TLS support via OpenSSL"

  depends_on "openssl3" if build.with? "openssl"

  def install
    # The build itself tries to set optimisation flags varying between -O1 & -O3 by default.
    ENV.no_optimization
    ENV.append "OPENSSL_DIR", "#{Formula["openssl3"].opt_prefix}" if build.with? "openssl"
    # Set compiler & interpreter name to avoid conflict with Ghostscript's gsc
    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --libdir=#{lib}/gambit-c
      --infodir=#{info}
      --docdir=#{doc}
      --enable-dynamic-clib
      --enable-compiler-name=gsc-gambit
      --enable-interpreter-name=gsi-gambit
    ]

    args << "--enable-openssl" if build.with? "openssl"
    args << "--enable-single-host" if build.with? "single"
    args << "--enable-shared" if build.with? "shared"

    system "./configure", *args
    system "make", "check" if build.with? "check"

    system "make"
    system "make", "install", "emacsdir=#{share}/emacs/site-lisp/#{name}"
  end

  test do
    system "#{bin}/gsi-gambit", "-e", '(print "hello world")'
  end

  # Allow the location of OpenSSL to be set during build.
  # https://github.com/gambit/gambit/pull/846 
  patch :p0, :DATA

end
__END__
--- configure
+++ configure
@@ -10221,8 +10221,11 @@ if test "$ENABLE_OPENSSL" = yes; then
 
   case "$target_os" in
     darwin*) # macOS ships an old version of the OpenSSL library, so it should
-             # be installed with "brew install openssl"
-             OPENSSL_DIR="/usr/local/opt/openssl@1.1"
+             # be installed with "brew install openssl" or another means and
+             # set the OPENSSL_DIR environment variable to prefix where installed.
+             if test "${OPENSSL_DIR+set}" != set; then
+               OPENSSL_DIR="/usr/local/opt/openssl@1.1"
+             fi
              if test "$ENABLE_OPENSSL_STATIC_LINK" = yes; then
                LIBS="$LIBS $OPENSSL_DIR/lib/libssl.a $OPENSSL_DIR/lib/libcrypto.a"
              else
