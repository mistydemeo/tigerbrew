# No head build supported; if you need head builds of Mercurial, do so outside
# of Homebrew.
class Mercurial < Formula
  desc "Scalable distributed version control system"
  homepage "https://www.mercurial-scm.org/"
  url "https://www.mercurial-scm.org/release/mercurial-6.5.1.tar.gz"
  sha256 "33f7de8d8b3607fa2b408cde4b8725e117eb0ad41926a787eaab409ca8a4fc2f"

  bottle do
    cellar :any_skip_relocation
    sha256 "fb1c3ca13bd02c862cce9475a515c8615c3680f0390f28d280a0b1474babf0c3" => :tiger_altivec
  end

  depends_on :python3

  def install
    ENV.minimal_optimization if MacOS.version <= :snow_leopard
    # GCC 4.0 doesn't support granular error settings, so the build breaks
    inreplace "setup.py", "-Werror=declaration-after-statement", "-Werror"

    system "make", "PREFIX=#{prefix}", "install-bin"
    # Install man pages, which come pre-built in source releases
    man1.install "doc/hg.1"
    man5.install "doc/hgignore.5", "doc/hgrc.5"

    # install the completion scripts
    bash_completion.install "contrib/bash_completion" => "hg-completion.bash"
    zsh_completion.install "contrib/zsh_completion" => "_hg"
  end

  test do
    system "#{bin}/hg", "init"
  end

  # Fix PowerPC build
  patch :p0, :DATA
end
__END__
--- mercurial/thirdparty/sha1dc/lib/sha1.c.orig 2023-04-11 20:39:20.000000000 +0000
+++ mercurial/thirdparty/sha1dc/lib/sha1.c
@@ -102,6 +102,10 @@
  */
 #define SHA1DC_BIGENDIAN

+#elif (defined(__APPLE__) && defined(__BIG_ENDIAN__) && !defined(SHA1DC_BIGENDIAN))
+/* older gcc compilers which are the default on Apple PPC do not define __BYTE_ORDER__ */
+#define SHA1DC_BIGENDIAN
+
 /* Not under GCC-alike or glibc or *BSD or newlib or <processor whitelist> or <os whitelist> */
 #elif defined(SHA1DC_ON_INTEL_LIKE_PROCESSOR)
 /*
