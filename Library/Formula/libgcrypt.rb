require "formula"

class Libgcrypt < Formula
  homepage "http://gnupg.org/"
  url "ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.6.1.tar.bz2"
  sha1 "f03d9b63ac3b17a6972fc11150d136925b702f02"

  bottle do
    cellar :any
    revision 1
    sha1 "097b7d905939f048c57e5b578fdbedfd9b2d5cbb" => :mavericks
    sha1 "fe4f770a092426bd9f92aa3d5fb3254cbdd5216f" => :mountain_lion
    sha1 "3fac80790da33ba3f43e2e57ca30bbd8d88fc3e9" => :lion
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
