class Bash < Formula
  desc "Bourne-Again SHell, a UNIX command interpreter"
  homepage "https://www.gnu.org/software/bash/"
  url "https://ftp.gnu.org/gnu/bash/bash-5.2.15.tar.gz"
  mirror "https://mirrors.ocf.berkeley.edu/gnu/bash/bash-5.2.15.tar.gz"
  mirror "https://mirrors.kernel.org/gnu/bash/bash-5.2.15.tar.gz"
  mirror "https://ftp.gnu.org/gnu/bash/bash-5.2.15.tar.gz"
  sha256 "13720965b5f4fc3a0d4b61dd37e7565c741da9a5be24edc2ae00182fc1b3588c"

  head "http://git.savannah.gnu.org/r/bash.git"

  bottle do
    sha256 "45860089958dc84d8988c9387fdad5ae30b714df3af36b98e9380d1ff835c94c" => :tiger_altivec
  end

  # Guard off missing definitions
  # https://savannah.gnu.org/patch/?10367
  patch :p0, :DATA

  depends_on "readline"

  def install
    # When built with SSH_SOURCE_BASHRC, bash will source ~/.bashrc when
    # it's non-interactively from sshd.  This allows the user to set
    # environment variables prior to running the command (e.g. PATH).  The
    # /bin/bash that ships with Mac OS X defines this, and without it, some
    # things (e.g. git+ssh) will break if the user sets their default shell to
    # Homebrew's bash instead of /bin/bash.
    ENV.append_to_cflags "-DSSH_SOURCE_BASHRC"

    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    In order to use this build of bash as your login shell,
    it must be added to /etc/shells.
    EOS
  end

  test do
    assert_equal "hello", shell_output("#{bin}/bash -c \"echo hello\"").strip
  end
end
__END__
--- examples/loadables/getconf.c.orig	2023-06-26 18:29:17.000000000 +0100
+++ examples/loadables/getconf.c	2023-06-26 18:35:06.000000000 +0100
@@ -269,9 +269,13 @@
 #ifdef _SC_AVPHYS_PAGES
     { "_AVPHYS_PAGES", _SC_AVPHYS_PAGES, SYSCONF },
 #endif
+#ifdef _NPROCESSORS_CONF
     { "_NPROCESSORS_CONF", _SC_NPROCESSORS_CONF, SYSCONF },
     { "_NPROCESSORS_ONLN", _SC_NPROCESSORS_ONLN, SYSCONF },
+#endif
+#ifdef _PHYS_PAGES
     { "_PHYS_PAGES", _SC_PHYS_PAGES, SYSCONF },
+#endif
 #ifdef _SC_ARG_MAX
     { "_POSIX_ARG_MAX", _SC_ARG_MAX, SYSCONF },
 #else
@@ -854,7 +858,9 @@
     { "SEM_VALUE_MAX", _SC_SEM_VALUE_MAX, SYSCONF },
 #endif
     { "SIGQUEUE_MAX", _SC_SIGQUEUE_MAX, SYSCONF },
+#ifdef _PC_FILESIZEBITS
     { "FILESIZEBITS", _PC_FILESIZEBITS, PATHCONF },
+#endif
 #ifdef _PC_ALLOC_SIZE_MIN
     { "POSIX_ALLOC_SIZE_MIN", _PC_ALLOC_SIZE_MIN, PATHCONF },
 #endif
@@ -870,7 +876,9 @@
 #ifdef _PC_REC_XFER_ALIGN
     { "POSIX_REC_XFER_ALIGN", _PC_REC_XFER_ALIGN, PATHCONF },
 #endif
+#ifdef _PC_SYMLINK_MAX
     { "SYMLINK_MAX", _PC_SYMLINK_MAX, PATHCONF },
+#endif
 #ifdef _PC_2_SYMLINKS
     { "POSIX2_SYMLINKS", _PC_2_SYMLINKS, PATHCONF },
 #endif
