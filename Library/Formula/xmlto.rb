class Xmlto < Formula
  desc "Convert XML to another format (based on XSL or other tools)"
  homepage "https://fedorahosted.org/xmlto/"
  url "https://releases.pagure.org/xmlto/xmlto-0.0.26.tar.bz2"
  sha256 "efb49b2fb3bc27c1a1e24fe34abf19b6bf6cbb40844e6fd58034cdf21c54b5ec"


  depends_on "docbook"
  depends_on "docbook-xsl"
  # Doesn't strictly depend on GNU getopt, but OS X system getopt(1)
  # does not support longopts in the optstring, so use GNU getopt.
  depends_on "gnu-getopt"

  # xmlto forces --nonet on xsltproc, which causes it to fail when
  # DTDs/entities aren't available locally.
  patch :DATA

  def install
    # GNU getopt is keg-only, so point configure to it
    ENV["GETOPT"] = Formula["gnu-getopt"].opt_prefix/"bin/getopt"
    # Find our docbook catalog
    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"

    ENV.deparallelize
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end
end


__END__
--- xmlto-0.0.25/xmlto.in.orig
+++ xmlto-0.0.25/xmlto.in
@@ -209,7 +209,7 @@
 export VERBOSE
 
 # Disable network entities
-XSLTOPTS="$XSLTOPTS --nonet"
+#XSLTOPTS="$XSLTOPTS --nonet"
 
 # The names parameter for the XSLT stylesheet
 XSLTPARAMS=""
