# No head build supported; if you need head builds of Mercurial, do so outside
# of Homebrew.
class Mercurial < Formula
  desc "Scalable distributed version control system"
  homepage "https://www.mercurial-scm.org/"
  url "https://www.mercurial-scm.org/release/mercurial-6.5.2.tar.gz"
  sha256 "afc39d7067976593c8332b8e97a12afd393b55037c5fb9c3cab1a42c7560f60a"

  bottle do
    cellar :any_skip_relocation
    sha256 "16695d8cf56854e015b1467585b1d3d3315ce2e67f8d5190f0fc7c9c8e155e61" => :tiger_altivec
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
