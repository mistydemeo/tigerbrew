class Clisp < Formula
  desc "GNU CLISP, a Common Lisp implementation"
  homepage "http://www.clisp.org/"
  url "http://ftpmirror.gnu.org/clisp/release/2.49/clisp-2.49.tar.bz2"
  mirror "https://ftp.gnu.org/gnu/clisp/release/2.49/clisp-2.49.tar.bz2"
  sha256 "8132ff353afaa70e6b19367a25ae3d5a43627279c25647c220641fed00f8e890"
  revision 2

  bottle do
    sha256 "3882ebb56f162524f9fb88800fb2cc84ffc07d1306558d0a3741924cc33af30c" => :tiger_altivec
  end

  depends_on "libsigsegv"
  depends_on "readline"

  fails_with :llvm do
    build 2334
    cause "Configure fails on XCode 4/Snow Leopard."
  end

  # stream.d (iconv): Condition "undef iconv" on whether it is
  # defined, not on platform.
  # https://github.com/rurban/clisp/commit/753cc2c5fc8896a3cc86e13f3fb51913be5014b2
  # clhs.lisp (open-http): Admit that HTTPS is not supported instead
  # of raising 'PARSE-INTEGER: substring "" does not have integer
  # syntax at position 0'.
  # https://github.com/rurban/clisp/commit/6fc696660ed83b4b04fdc237466b4be164bbc875
  # streams.tst [clisp]: Disable both CLHS and IMPNOTES so that DESCRIBE does no internet
  # connections, then restore them.
  # https://github.com/rurban/clisp/commit/6ca5da6ec410fda466e442da275f230e76d182fc
  patch :DATA

  patch :p0 do
    url "https://trac.macports.org/export/89054/trunk/dports/lang/clisp/files/patch-src_lispbibl_d.diff"
    sha256 "fd4e8a0327e04c224fb14ad6094741034d14cb45da5b56a2f3e7c930f84fd9a0"
  end

  def install
    ENV.deparallelize # This build isn't parallel safe.
    ENV.no_optimization # Build itself sets optimisation flags.

    # Clisp requires to select word size explicitly this way,
    # set it in CFLAGS won't work.
    ENV["CC"] = "#{ENV.cc} -m#{MacOS.prefer_64_bit? ? 64 : 32}"

    system "./configure", "--prefix=#{prefix}",
                          "--with-readline=yes"

    cd "src" do
      # Multiple -O options will be in the generated Makefile,
      # make Homebrew's the last such option so it's effective.
      inreplace "Makefile" do |s|
        s.change_make_var! "CFLAGS", "#{s.get_make_var("CFLAGS")} #{ENV["CFLAGS"]}"
      end

      # The ulimit must be set, otherwise `make` will fail and tell you to do so
      system "ulimit -s 16384 && make"

      if MacOS.version >= :lion
        opoo <<-EOS.undent
           `make check` fails so we are skipping it.
           However, there will likely be other issues present.
           Please take them upstream to the clisp project itself.
        EOS
      else
        # Considering the complexity of this package, a self-check is highly recommended.
        system "make", "check"
      end

      system "make", "install"
    end
  end

  test do
    system "#{bin}/clisp", "--version"
  end
end

__END__
diff --git a/src/stream.d b/src/stream.d
index 5345ed6..cf14e29 100644
--- a/src/stream.d
+++ b/src/stream.d
@@ -3994,7 +3994,7 @@ global object iconv_range (object encoding, uintL start, uintL end, uintL maxint
 nonreturning_function(extern, error_unencodable, (object encoding, chart ch));
 
 /* Avoid annoying warning caused by a wrongly standardized iconv() prototype. */
-#ifdef GNU_LIBICONV
+#if defined(GNU_LIBICONV) && defined(iconv)
   #undef iconv
   #define iconv(cd,inbuf,inbytesleft,outbuf,outbytesleft) \
     libiconv(cd,(ICONV_CONST char **)(inbuf),inbytesleft,outbuf,outbytesleft)
--- a/src/clhs.lisp.orig	2010-06-18 20:51:42.000000000 +0100
+++ b/src/clhs.lisp	2023-07-31 13:13:29.000000000 +0100
@@ -1,4 +1,4 @@
-;;; Copyright (C) 2000-2008 by Sam Steingold
+;;; Sam Steingold 2000-2008, 2010-2011, 2017
 ;;; This file is a part of CLISP (http://clisp.cons.org), and, as such,
 ;;; is distributed under the GNU GPL (http://www.gnu.org/copyleft/gpl.html)
 
@@ -93,6 +93,17 @@
           (t (format t "~s: no browser specified; please point your browser at
  --> <URL:~a>~%" 'browse-url url)))))
 
+(defun starts-with-p (string prefix)
+  "Check whether the string starts with the supplied prefix (case-insensitive)."
+  (string-equal string prefix :end1 (min (length string) (length prefix))))
+#+(or)                          ; not worth it
+(define-compiler-macro starts-with-p (string prefix &whole form)
+  "Inline and pre-compute prefix length."
+  (print (list string prefix form))
+  (if (stringp prefix)
+      `(string-equal ,string ,prefix :end1 (min (length ,string) ,(length prefix)))
+      form))
+
 (defvar *http-log-stream* (make-synonym-stream '*terminal-io*))
 ;;; keep in sync with clocc/cllib/url.lisp
 (defvar *http-proxy* nil
@@ -105,10 +116,8 @@
 set *HTTP-PROXY*, and return it; otherwise just return *HTTP-PROXY*."
   (when (or proxy-p (and (null *http-proxy*) proxy-string))
     (check-type proxy-string string)
-    (let* ((start (if (string-equal #1="http://" proxy-string
-                                    :end2 (min (length proxy-string)
-                                               #2=#.(length #1#)))
-                      #2# 0))
+    (let* ((start (if (starts-with-p proxy-string #1="http://")
+                      #.(length #1#) 0))
            (at (position #\@ proxy-string :start start))
            (colon (position #\: proxy-string :start (or at start)))
            (slash (position #\/ proxy-string :start (or colon at start))))
@@ -133,13 +142,12 @@
              (when ,(first var) (CLOSE ,(first var) :ABORT T)))))))
 (defun open-http (url &key (if-does-not-exist :error)
                   ((:log *http-log-stream*) *http-log-stream*))
-  (unless (string-equal #1="http://" url
-                        :end2 (min (length url) #2=#.(length #1#)))
+  (unless (starts-with-p url #1="http://")
     (error "~S: ~S is not an HTTP URL" 'open-http url))
   (format *http-log-stream* "~&;; connecting to ~S..." url)
   (force-output *http-log-stream*)
   (http-proxy)
-  (let* ((host-port-end (position #\/ url :start #2#))
+  (let* ((host-port-end (position #\/ url :start #2=#.(length #1#)))
          (port-start (position #\: url :start #2# :end host-port-end))
          (url-host (subseq url #2# (or port-start host-port-end)))
          (host (if *http-proxy* (second *http-proxy*) url-host))
@@ -189,33 +197,33 @@
            (return-from open-http nil))))
     (if (>= code 300)        ; redirection
         (loop :for res = (read-line sock)
-          :until (string-equal #3="Location: " res
-                               :end2 (min (length res) #4=#.(length #3#)))
-          :finally (let ((new-url (subseq res #4#)))
+          :until (starts-with-p res #3="Location: ")
+          :finally (let ((new-url (subseq res #.(length #3#))))
                      (format *http-log-stream* " --> ~S~%" new-url)
-                     (unless (string-equal #1# new-url
-                                           :end2 (min (length new-url) #2#))
+                     (when (starts-with-p new-url "https://")
+                       (error (TEXT "~S(~S): HTTPS protocol is not supported yet")
+                              'open-http new-url))
+                     (unless (starts-with-p new-url #1#)
                        (setq new-url (string-concat #1# host new-url)))
                      (return-from open-http (open-http new-url))))
         ;; drop response headers
         (loop :for line = (read-line sock) :while (plusp (length line)) :do
-          (when (string-equal #5="Content-Length: " line
-                              :end2 (min (length line) #6=#.(length #5#)))
+          (when (starts-with-p line #5="Content-Length: ")
             (format *http-log-stream* "...~:D bytes"
-                    (setq content-length (parse-integer line :start #6#))))
+                    (setq content-length (parse-integer line :start #.(length #5#)))))
           :finally (terpri)))
     (values sock content-length)))
 (defun open-url (path &rest options &aux (len (length path)))
-  (cond ((string-equal #1="http://" path :end2 (min len #.(length #1#)))
+  (cond ((starts-with-p path "http://")
          (apply #'open-http path options))
-        ((string-equal #2="file:/" path :end2 (min len #3=#.(length #2#)))
-         ;; Tomas Zellerin writes in bug 1494059:
+        ((starts-with-p path #1="file:/")
+         ;; Tomas Zellerin writes in bug#344:
          ;; I think that proper RFC compliant URL of this kind is
          ;; file://<machine>/<path>, where machine may be the empty string
          ;; for localhost and path should be an absolute path (including
          ;; the leading slash on Unix), but browsers usually do not require
          ;; four slashes in row.
-         (let ((path-beg (position #\/ path :test-not #'eql :start #3#)))
+         (let ((path-beg (position #\/ path :test-not #'eql :start #.(length #1#))))
            ;; we first try stripping all leading slashes to catch things like
            ;; file:///c:/foo/bar and then resort to keeping one leading #\/
            (apply #'open (or #+(or win32 cygwin)
--- a/tests/streams.tst.orig	2023-07-31 14:39:19.000000000 +0100
+++ b/tests/streams.tst	2023-07-31 14:44:20.000000000 +0100
@@ -7,8 +7,15 @@
 #+LISPWORKS "#<Broadcast stream to ()>"
 #-(or XCL CLISP AKCL ECL ALLEGRO CMU SBCL OpenMCL LISPWORKS) UNKNOWN
 
-;; make sure that DESCRIBE does not try to look up CLHS documentation
-#+clisp (defun custom:clhs-root () nil) #+clisp ext:clhs-root
+;; make sure that DESCRIBE does not try to look up CLHS & IMPNOTES documentation
+#+clisp
+(progn
+  (defparameter saved-clhs-root #'custom:clhs-root)
+  (defun custom:clhs-root () nil)
+  (defparameter saved-impnotes-root #'custom:impnotes-root)
+  (defun custom:impnotes-root () nil)
+  NIL)
+#+clisp NIL
 
 ;; CLOSE should not delete information about
 ;; element type, direction, and external format
@@ -1241,6 +1248,13 @@
 "
  "")
 
+#+clisp
+(progn
+  (setf (fdefinition 'custom:clhs-root) saved-clhs-root
+        (fdefinition 'custom:impnotes-root) saved-impnotes-root)
+  (list (stringp (custom:clhs-root)) (stringp (custom:impnotes-root))))
+#+clisp (T T)
+
 (progn
   (symbol-cleanup 's)
   (symbol-cleanup 's1)
@@ -1261,6 +1275,8 @@
   (symbol-cleanup 'c4)
   (symbol-cleanup 'inptw)
   (symbol-cleanup 'sy)
+  (symbol-cleanup 'saved-clhs-root)
+  (symbol-cleanup 'saved-impnotes-root)
   (symbol-cleanup 'tw)
   (symbol-cleanup 'ec)
   (symbol-cleanup 'str1)
