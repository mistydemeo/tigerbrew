class Screen < Formula
  desc "Terminal multiplexer with VT100/ANSI terminal emulation"
  homepage "https://www.gnu.org/software/screen/"
  url "https://ftpmirror.gnu.org/gnu/screen/screen-4.9.1.tar.gz"
  mirror "https://ftp.gnu.org/gnu/screen/screen-4.9.1.tar.gz"
  sha256 "26cef3e3c42571c0d484ad6faf110c5c15091fbf872b06fa7aa4766c7405ac69"
  license "GPL-3.0-or-later"

  bottle do
  end

  # Match behaviour of old screen and set TIOCSCTTY, otherwise screen complains on Tiger:
  # fgtty: Inappropriate ioctl for device
  # utmp(5) was deprecated in Leopard.
  # /var/run/utmp: No such file or directory
  # fix CVE-2025-46802: attacher.c - prevent temporary 0666 mode on PTYs
  # https://cgit.git.savannah.gnu.org/cgit/screen.git/commit/?h=screen-v4&id=049b26b22e197ba3be9c46e5c193032e01a4724a
  # fix CVE-2025-46804: avoid file existence test information leaks
  # https://cgit.git.savannah.gnu.org/cgit/screen.git/commit/?h=screen-v4&id=e0eef5aac453fa98a2664416a56c50ad1d00cb30
  # fix CVE-2025-46805: socket.c - don't send signals with root privileges
  # https://cgit.git.savannah.gnu.org/cgit/screen.git/commit/?h=screen-v4&id=161f85b98b7e1d5e4893aeed20f4cdb5e3dfaaa4
  patch :p0, :DATA

  depends_on "libxcrypt"
  depends_on "ncurses"

  def install
    args = %W[
      --prefix=#{prefix}
      --mandir=#{man}
      --infodir=#{info}
      --enable-pam
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    system bin/"screen", "-h"
  end
end
__END__
--- tty.sh.orig	2025-11-03 13:56:41.000000000 +0000
+++ tty.sh	2025-11-03 13:57:24.000000000 +0000
@@ -832,7 +832,7 @@
   /*
    * Under BSD we have to set the controlling terminal again explicitly.
    */
-# if (defined(__FreeBSD_kernel__) || defined(__DragonFly__) || defined(__GNU__) || defined(__OpenBSD__)) && defined(TIOCSCTTY)
+# if (defined(__FreeBSD_kernel__) || defined(__DragonFly__) || defined(__APPLE__) || defined(__GNU__) || defined(__OpenBSD__)) && defined(TIOCSCTTY)
   ioctl(fd, TIOCSCTTY, (char *)0);
 # endif
 
--- config.h.in.orig	2025-11-04 13:34:16.000000000 +0000
+++ config.h.in	2025-11-04 13:38:55.000000000 +0000
@@ -192,7 +192,7 @@
  * If screen is installed with permissions to update /etc/utmp (such
  * as if it is installed set-uid root), define UTMPOK.
  */
-#define UTMPOK
+#undef UTMPOK
 
 /* Set LOGINDEFAULT to one (1)
  * if you want entries added to /etc/utmp by default, else set it to
--- attacher.c.orig	2023-08-16 01:29:26.000000000 +0100
+++ attacher.c	2025-11-04 14:40:47.000000000 +0000
@@ -73,7 +73,6 @@
 #ifdef MULTIUSER
 extern char *multi;
 extern int multiattach, multi_uid, own_uid;
-extern int tty_mode, tty_oldmode;
 # ifndef USE_SETEUID
 static int multipipe[2];
 # endif
@@ -160,9 +159,6 @@
 
       if (pipe(multipipe))
 	Panic(errno, "pipe");
-      if (chmod(attach_tty, 0666))
-	Panic(errno, "chmod %s", attach_tty);
-      tty_oldmode = tty_mode;
       eff_uid = -1;	/* make UserContext fork */
       real_uid = multi_uid;
       if ((ret = UserContext()) <= 0)
@@ -174,11 +170,6 @@
 	    Panic(errno, "UserContext");
 	  close(multipipe[1]);
 	  read(multipipe[0], &dummy, 1);
-	  if (tty_oldmode >= 0)
-	    {
-	      chmod(attach_tty, tty_oldmode);
-	      tty_oldmode = -1;
-	    }
 	  ret = UserStatus();
 #ifdef LOCK
 	  if (ret == SIG_LOCK)
@@ -224,9 +215,6 @@
       xseteuid(multi_uid);
       xseteuid(own_uid);
 #endif
-      if (chmod(attach_tty, 0666))
-	Panic(errno, "chmod %s", attach_tty);
-      tty_oldmode = tty_mode;
     }
 # endif /* USE_SETEUID */
 #endif /* MULTIUSER */
@@ -423,13 +411,6 @@
       ContinuePlease = 0;
 # ifndef USE_SETEUID
       close(multipipe[1]);
-# else
-      xseteuid(own_uid);
-      if (tty_oldmode >= 0)
-        if (chmod(attach_tty, tty_oldmode))
-          Panic(errno, "chmod %s", attach_tty);
-      tty_oldmode = -1;
-      xseteuid(real_uid);
 # endif
     }
 #endif
@@ -505,14 +486,6 @@
 	  close(s);
 	}
     }
-#ifdef MULTIUSER
-  if (tty_oldmode >= 0)
-    {
-      if (setuid(own_uid))
-        Panic(errno, "setuid");
-      chmod(attach_tty, tty_oldmode);
-    }
-#endif
   exit(0);
   SIGRETURN;
 }
--- screen.c.orig	2023-08-16 01:29:26.000000000 +0100
+++ screen.c	2025-11-04 14:40:47.000000000 +0000
@@ -230,8 +230,6 @@
 int multi_uid;
 int own_uid;
 int multiattach;
-int tty_mode;
-int tty_oldmode = -1;
 #endif
 
 char HostName[MAXSTR];
@@ -1009,9 +1007,6 @@
 
     /* ttyname implies isatty */
     SetTtyname(true, &st);
-#ifdef MULTIUSER
-    tty_mode = (int)st.st_mode & 0777;
-#endif
 
     fl = fcntl(0, F_GETFL, 0);
     if (fl != -1 && (fl & (O_RDWR|O_RDONLY|O_WRONLY)) == O_RDWR)
@@ -1127,15 +1122,28 @@
 #endif
   }
 
-  if (stat(SockPath, &st) == -1)
-    Panic(errno, "Cannot access %s", SockPath);
-  else
-    if (!S_ISDIR(st.st_mode))
+  if (stat(SockPath, &st) == -1) {
+    if (eff_uid == real_uid) {
+      Panic(errno, "Cannot access %s", SockPath);
+    } else {
+      Panic(0, "Error accessing %s", SockPath);
+    }
+  } else if (!S_ISDIR(st.st_mode)) {
+    if (eff_uid == real_uid || st.st_uid == real_uid) {
       Panic(0, "%s is not a directory.", SockPath);
+    } else {
+      Panic(0, "Error accessing %s", SockPath);
+    }
+  }
 #ifdef MULTIUSER
   if (multi) {
-    if ((int)st.st_uid != multi_uid)
-      Panic(0, "%s is not the owner of %s.", multi, SockPath);
+    if ((int)st.st_uid != multi_uid) {
+      if (eff_uid == real_uid || st.st_uid == real_uid) {
+        Panic(0, "%s is not the owner of %s.", multi, SockPath);
+      } else {
+        Panic(0, "Error accessing %s", SockPath);
+      }
+    }
   }
   else
 #endif
@@ -1149,9 +1157,13 @@
       Panic(0, "You are not the owner of %s.", SockPath);
 #endif
   }
-
-  if ((st.st_mode & 0777) != 0700)
-    Panic(0, "Directory %s must have mode 700.", SockPath);
+  if ((st.st_mode & 0777) != 0700) {
+    if (eff_uid == real_uid || st.st_uid == real_uid) {
+      Panic(0, "Directory %s must have mode 700.", SockPath);
+    } else {
+      Panic(0, "Error accessing %s", SockPath);
+    }
+  }
   if (SockMatch && index(SockMatch, '/'))
     Panic(0, "Bad session name '%s'", SockMatch);
   SockName = SockPath + strlen(SockPath) + 1;
@@ -1189,8 +1201,14 @@
       else
         exit(9 + (fo || oth ? 1 : 0) + fo);
     }
-    if (fo == 0)
-      Panic(0, "No Sockets found in %s.\n", SockPath);
+    if (fo == 0) {
+      if (eff_uid == real_uid || st.st_uid == real_uid) {
+        Panic(0, "No Sockets found in %s.\n", SockPath);
+      } else {
+        Panic(0, "Error accessing %s", SockPath);
+      }
+    }
+
     Msg(0, "%d Socket%s in %s.", fo, fo > 1 ? "s" : "", SockPath);
     eexit(0);
   }
@@ -2170,20 +2188,6 @@
       if (D_userpid)
         Kill(D_userpid, SIG_BYE);
     }
-#ifdef MULTIUSER
-  if (tty_oldmode >= 0) {
-
-# ifdef USE_SETEUID
-    if (setuid(own_uid))
-      xseteuid(own_uid);	/* may be a loop. sigh. */
-# else
-      setuid(own_uid);
-# endif
-
-    debug1("Panic: changing back modes from %s\n", attach_tty);
-    chmod(attach_tty, tty_oldmode);
-  }
-#endif
   eexit(1);
 }
 
--- socket.c.orig	2023-08-16 01:29:26.000000000 +0100
+++ socket.c	2025-11-04 14:38:37.000000000 +0000
@@ -169,8 +169,13 @@
   xsetegid(real_gid);
 #endif
 
-  if ((dirp = opendir(SockPath)) == 0)
-    Panic(errno, "Cannot opendir %s", SockPath);
+  if ((dirp = opendir(SockPath)) == 0) {
+    if (eff_uid == real_uid) {
+      Panic(errno, "Cannot opendir %s", SockPath);
+    } else {
+      Panic(0, "Error accessing %s", SockPath);
+    }
+  }
 
   slist = 0;
   slisttail = &slist;
@@ -826,6 +831,11 @@
   return UserStatus();
 }
 
+static void KillUnpriv(pid_t pid, int sig) {
+    UserContext();
+    UserReturn(kill(pid, sig));
+}
+
 #ifdef hpux
 /*
  * From: "F. K. Bruner" <napalm@ugcs.caltech.edu>
@@ -911,14 +921,14 @@
             {
 	      Msg(errno, "Could not perform necessary sanity checks on pts device.");
 	      close(i);
-	      Kill(pid, SIG_BYE);
+	      KillUnpriv(pid, SIG_BYE);
 	      return -1;
             }
           if (strcmp(ttyname_in_ns, m->m_tty))
             {
 	      Msg(errno, "Attach: passed fd does not match tty: %s - %s!", ttyname_in_ns, m->m_tty[0] != '\0' ? m->m_tty : "(null)");
 	      close(i);
-	      Kill(pid, SIG_BYE);
+	      KillUnpriv(pid, SIG_BYE);
 	      return -1;
 	    }
 	  /* m->m_tty so far contains the actual name of the pts device in the
@@ -935,19 +945,19 @@
 	{
 	  Msg(errno, "Attach: passed fd does not match tty: %s - %s!", m->m_tty, myttyname ? myttyname : "NULL");
 	  close(i);
-	  Kill(pid, SIG_BYE);
+	  KillUnpriv(pid, SIG_BYE);
 	  return -1;
 	}
     }
   else if ((i = secopen(m->m_tty, O_RDWR | O_NONBLOCK, 0)) < 0)
     {
       Msg(errno, "Attach: Could not open %s!", m->m_tty);
-      Kill(pid, SIG_BYE);
+      KillUnpriv(pid, SIG_BYE);
       return -1;
     }
 #ifdef MULTIUSER
   if (attach)
-    Kill(pid, SIGCONT);
+    KillUnpriv(pid, SIGCONT);
 #endif
 
 #if defined(ultrix) || defined(pyr) || defined(NeXT)
@@ -960,7 +970,7 @@
 	{
 	  write(i, "Attaching from inside of screen?\n", 33);
 	  close(i);
-	  Kill(pid, SIG_BYE);
+	  KillUnpriv(pid, SIG_BYE);
 	  Msg(0, "Attach msg ignored: coming from inside.");
 	  return -1;
 	}
@@ -971,7 +981,7 @@
 	  {
 	      write(i, "Access to session denied.\n", 26);
 	      close(i);
-	      Kill(pid, SIG_BYE);
+	      KillUnpriv(pid, SIG_BYE);
 	      Msg(0, "Attach: access denied for user %s.", user);
 	      return -1;
 	  }
@@ -1289,7 +1299,7 @@
             Msg(0, "Query attempt with bad pid(%d)!", m.m.command.apid);
           }
           else {
-            Kill(m.m.command.apid,
+            KillUnpriv(m.m.command.apid,
                (queryflag >= 0)
                    ? SIGCONT
                    : SIG_BYE); /* Send SIG_BYE if an error happened */
