class Libxmlsec1 < Formula
  desc "XML security library"
  homepage "https://www.aleksey.com/xmlsec/"
  url "https://www.aleksey.com/xmlsec/download/xmlsec1-1.2.20.tar.gz"
  sha256 "3221593ca50f362b546a0888a1431ad24be1470f96b2469c0e0df5e1c55e7305"


  depends_on "pkg-config" => :build
  depends_on "libxml2" if MacOS.version <= :lion
  # Yes, it wants both ssl/tls variations.
  depends_on "openssl" => :recommended
  depends_on "gnutls" => :recommended
  depends_on "libgcrypt" if build.with? "gnutls"

  # Add HOMEBREW_PREFIX/lib to dl load path
  patch :DATA

  def install
    args = ["--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--disable-crypto-dl",
            "--disable-apps-crypto-dl"
           ]

    args << "--with-openssl=#{Formula["openssl"].opt_prefix}" if build.with? "openssl"
    args << "--with-libxml=#{Formula["libxml2"].opt_prefix}" if build.with? "libxml2"

    system "./configure", *args
    system "make", "install"
  end
end

__END__
diff --git a/src/dl.c b/src/dl.c
index 6e8a56a..0e7f06b 100644
--- a/src/dl.c
+++ b/src/dl.c
@@ -141,6 +141,7 @@ xmlSecCryptoDLLibraryCreate(const xmlChar* name) {
     }

 #ifdef XMLSEC_DL_LIBLTDL
+    lt_dlsetsearchpath("HOMEBREW_PREFIX/lib");
     lib->handle = lt_dlopenext((char*)lib->filename);
     if(lib->handle == NULL) {
         xmlSecError(XMLSEC_ERRORS_HERE,
