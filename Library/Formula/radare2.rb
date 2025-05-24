class Radare2 < Formula
  desc "Reverse engineering framework"
  homepage "https://radare.org"
  url "https://github.com/radareorg/radare2/archive/refs/tags/5.9.0.tar.gz"
  sha256 "f3280abd5ec70d58f9fd3853071670cfbb1e155d58e884aa43231f6ae10e0b59"
  license "LGPL-3.0-only"
  head "https://github.com/radareorg/radare2.git", branch: "master"


  # Fix Darwin/PowerPC support
  patch :p0, :DATA

  depends_on "pkg-config" => :build
  depends_on "capstone"
  depends_on "make" => :build
  depends_on "git" => :build
  depends_on "ld64" => :build
  depends_on "lz4"
  depends_on "openssl3"
  depends_on "xxhash"

  def install
    system "./configure", "--prefix=#{prefix}", "--with-ssl", "--with-syscapstone", "--with-syslz4", "--with-sysxxhash"
    system "gmake"
    system "gmake", "install"
  end

  test do
    assert_match "radare2 #{version}", shell_output("#{bin}/r2 -v")
  end
end
__END__
--- libr/arch/p/bpf/plugin.c.orig	2024-04-01 15:32:40.000000000 +0100
+++ libr/arch/p/bpf/plugin.c	2024-04-01 15:32:56.000000000 +0100
@@ -613,7 +613,7 @@
 static bool parse_instruction(RBpfSockFilter *f, BPFAsmParser *p, ut64 pc) {
 	const char *mnemonic_tok = token_next (p);
 	PARSE_NEED_TOKEN (mnemonic_tok);
-	int mlen = strnlen (mnemonic_tok, 5);
+	int mlen = r_str_nlen (mnemonic_tok, 5);
 	if (mlen < 2 || mlen > 4) {
 		R_LOG_ERROR ("invalid mnemonic");
 	}
--- libr/debug/p/native/xnu/xnu_threads.c.orig	2024-04-01 16:03:08.000000000 +0100
+++ libr/debug/p/native/xnu/xnu_threads.c	2024-04-01 16:13:17.000000000 +0100
@@ -140,7 +140,7 @@
 # ifndef PPC_DEBUG_STATE32
 # define PPC_DEBUG_STATE32 1
 # endif
-	ppc_debug_state_t *regs;
+	//ppc_debug_state_t *regs;
 	//thread->flavor = PPC_DEBUG_STATE32;
 	//thread->count  = R_MIN (thread->count, sizeof (regs->uds.ds32));
 	return false;
@@ -264,6 +264,7 @@
 				     sizeof (x86_thread_state64_t) :
 				     sizeof (x86_thread_state32_t);
 #endif
+#if !__POWERPC__
 	rc = thread_get_state (thread->port, thread->flavor,
 			       (thread_state_t)regs, &thread->count);
 
@@ -279,6 +280,7 @@
 		if (rc != KERN_SUCCESS) {
 			R_LOG_WARN ("failed to convert %d", rc);
 		}
+#endif
 #if  __arm64e__
 		else {
 			if (dbg->bits == R_SYS_BITS_64) {
@@ -286,7 +288,9 @@
 			}
 		}
 #endif
+#if !__POWERPC__
 	}
+#endif
 	if (rc != KERN_SUCCESS) {
 		r_sys_perror (__FUNCTION__);
 		thread->count = 0;
--- libr/debug/p/native/xnu/xnu_debug.c.orig	2024-04-01 16:19:17.000000000 +0100
+++ libr/debug/p/native/xnu/xnu_debug.c	2024-04-01 16:23:16.000000000 +0100
@@ -479,8 +479,8 @@
 		size_t buf_size = R_MIN (size, th->state_size);
 		memcpy (th->state, buf, buf_size);
 #endif
-#endif
 		}
+#endif
 		ret = xnu_thread_set_gpr (dbg, th);
 		break;
 	}
--- libr/core/cmd_anal.inc.c.orig	2024-04-01 18:46:33.000000000 +0100
+++ libr/core/cmd_anal.inc.c	2024-04-01 18:47:28.000000000 +0100
@@ -8532,7 +8532,7 @@
 					envp[i] = arg;
 				}
 				envp[i] = 0;
-#if R2__UNIX__
+#if R2__UNIX__ && !__POWERPC__
 				if (strstr (input, "$env")) {
 					extern char **environ;
 					cmd_debug_stack_init (core, argc, argv, environ);
--- libr/util/file.c.orig	2024-04-01 23:23:50.000000000 +0100
+++ libr/util/file.c	2024-04-01 23:34:04.000000000 +0100
@@ -227,6 +227,10 @@
 
 R_API char *r_file_abspath_rel(const char *cwd, const char *file) {
 	char *ret = NULL;
+	char *abspath = NULL;
+	#if !defined(_POSIX_VERSION) || _POSIX_VERSION < 200809L
+ 	char resolved_path[PATH_MAX] = { 0 };
+	#endif
 	if (!file || !*file || !strcmp (file, ".") || !strcmp (file, "./")) {
 		return r_sys_getdir ();
 	}
@@ -267,7 +271,15 @@
 		ret = strdup (file);
 	}
 #if R2__UNIX__ && !__wasi__
-	char *abspath = realpath (ret, NULL);
+	#if !defined(_POSIX_VERSION) || _POSIX_VERSION < 200809L
+ 	/* variable path length not supported by glibc < 2.3, Solaris < 11, Mac OS X < 10.5 */
+ 	errno = 0;
+ 	if ((abspath = realpath(ret, resolved_path)) != NULL) {
+ 		abspath = strdup(abspath);
+        }
+	#else
+	abspath = realpath (ret, NULL);
+	#endif
 	if (abspath) {
 		free (ret);
 		ret = abspath;
