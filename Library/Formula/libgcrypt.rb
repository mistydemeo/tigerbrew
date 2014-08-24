require "formula"

class Libgcrypt < Formula
  homepage "https://gnupg.org/"
  url "ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.6.2.tar.bz2"
  mirror "ftp://mirror.tje.me.uk/pub/mirrors/ftp.gnupg.org/libgcrypt/libgcrypt-1.6.2.tar.bz2"
  sha1 "cc31aca87e4a3769cb86884a3f5982b2cc8eb7ec"

  bottle do
    cellar :any
    sha1 "df22b7aa31f80e30ca6b8272219c5e79637fdd82" => :mavericks
    sha1 "241ab6c4f2ba2117aceba8ff6d43a740dcd825fc" => :mountain_lion
    sha1 "26f5294c07110d3201a1e13f6da9d54a299014a5" => :lion
  end

  depends_on "libgpg-error"

  option :universal

  resource "config.h.ed" do
    url "http://trac.macports.org/export/113198/trunk/dports/devel/libgcrypt/files/config.h.ed"
    version "113198"
    sha1 "136f636673b5c9d040f8a55f59b430b0f1c97d7a"
  end if build.universal?

  # Otherwise PPC darwin will attempt to build x86-only code and blow up
  # Reported upstream: https://bugs.g10code.com/gnupg/issue1616
  def patches; DATA; end

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-asm",
                          "--with-gpg-error-prefix=#{Formula["libgpg-error"].opt_prefix}"

    if build.universal?
      buildpath.install resource("config.h.ed")
      system "ed -s - config.h <config.h.ed"
    end

    # Parallel builds work, but only when run as separate steps
    system "make"
    system "make", "check"
    system "make", "install"
  end
end

__END__
diff --git a/mpi/config.links b/mpi/config.links
index 0217d35..f5bfea3 100644
--- a/mpi/config.links
+++ b/mpi/config.links
@@ -44,7 +44,11 @@ echo '/* created by config.links - do not edit */' >./mpi/asm-syntax.h
 echo "/* Host: ${host} */" >>./mpi/asm-syntax.h

 case "${host}" in
-    powerpc-apple-darwin*          | \
+    powerpc-apple-darwin*)
+       echo '/* No working assembler modules available */' >>./mpi/asm-syntax.h
+       path=""
+       mpi_cpu_arch="ppc"
+       ;;
     i[34567]86*-*-openbsd[12]*     | \
     i[34567]86*-*-openbsd3.[0123]*)
        echo '/* No working assembler modules available */' >>./mpi/asm-syntax.h
