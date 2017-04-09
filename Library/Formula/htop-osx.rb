class HtopOsx < Formula
  desc "Improved top (interactive process viewer) for OS X"
  homepage "https://github.com/max-horvath/htop-osx"
  url "https://github.com/max-horvath/htop-osx/archive/0.8.2.7.tar.gz"
  sha256 "a93be5c9d8a68081590b1646a0f10fb90e966e306560c3b141a61b3849446b72"

  bottle do
    sha256 "d127accb5266fc5522cecc6e93a6039b978a7abbd6be9765b9991b72602a3459" => :el_capitan
    sha256 "c4f4c2be9f6bda38bef8e57570cb02ec2a60738b5e3e6b27c189e493582daf66" => :yosemite
    sha256 "1e3fa7862bfcef0eed646b7c2b7f1d3ec491404b2c9312ae1045bb78b8059f30" => :mavericks
    sha256 "611c4ee686babb880828510fd3b1cfa247aa1e0ba6cb60401e8ad5c6cac1fc75" => :mountain_lion
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  # Tiger does not have backtrace nor the 64-bits compatible kernel APIs
  patch :DATA if MacOS.version < :leopard

  def install
    # Otherwise htop will segfault when resizing the terminal
    ENV.no_optimization if ENV.compiler == :clang

    system "./autogen.sh"
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install", "DEFAULT_INCLUDES='-iquote .'"
  end

  def caveats; <<-EOS.undent
    htop-osx requires root privileges to correctly display all running processes.
    so you will need to run `sudo htop`.
    You should be certain that you trust any software you grant root privileges.
    EOS
  end

  test do
    ENV["TERM"] = "xterm"
    pipe_output("#{bin}/htop", "q")
    assert $?.success?
  end
end

__END__
diff --git a/CRT.c b/CRT.c
index b1f60a0..f3f26f0 100644
--- a/CRT.c
+++ b/CRT.c
@@ -127,13 +127,8 @@ int CRT_colors[LAST_COLORELEMENT] = { 0 };
 char* CRT_termType;
 
 static void CRT_handleSIGSEGV(int signal) {
-   void *array[10];
-   size_t size;
-   size = backtrace(array, 10);
-
    CRT_done();
    fprintf(stderr, "htop " VERSION " aborted. Please report bug at http://htop.sf.net\n");
-   backtrace_symbols_fd(array, size, STDERR_FILENO);
    exit(1);
 }
 
diff --git a/ProcessList.c b/ProcessList.c
index 0f4ebf3..ea7b191 100644
--- a/ProcessList.c
+++ b/ProcessList.c
@@ -737,12 +737,9 @@ ProcessList_decodeState( int st ) {
 static bool
 ProcessList_getSwap( ProcessList * this ) {
   struct xsw_usage swap;
-  size_t bufSize = 0;
+  size_t bufSize = sizeof( swap );
   int mib[2] = { CTL_VM, VM_SWAPUSAGE };
 
-  if ( sysctl( mib, 2, NULL, &bufSize, NULL, 0 ) < 0 )
-    die( "Failure calling sysctl" );
-
   if ( sysctl( mib, 2, &swap, &bufSize, NULL, 0 ) < 0 )
     die( "Failure calling sysctl" );
 
diff --git a/smc.c b/smc.c
index 058c809..5c6d432 100644
--- a/smc.c
+++ b/smc.c
@@ -160,39 +160,15 @@ SMCCall(int index,   SMCParamStruct* input,  SMCParamStruct* output)
     if (conn == 0 && (result = SMCOpen()) != 0)
         return result;
 
-    result = IOConnectCallMethod(
-                                          conn, 
-                                          kSMCUserClientOpen, 
-                                          NULL, 
-                                          0, 
-                                          NULL, 
-                                          0, 
-                                          NULL, 
-                                          NULL, 
-                                          NULL, 
-                                          NULL);
-    if (kIOReturnSuccess != result)
-        return result;
-     
     size_t outSize = sizeof(SMCParamStruct);
-    result = IOConnectCallStructMethod(
-                                       conn, 
-                                       index, 
-                                       input, 
-                                       sizeof(SMCParamStruct), 
-                                       output, 
-                                       &outSize);
-    IOConnectCallMethod(
-                        conn, 
-                        kSMCUserClientClose, 
-                        NULL, 
-                        0, 
-                        NULL, 
-                        0, 
-                        NULL, 
-                        NULL, 
-                        NULL, 
-                        NULL);
+    result = IOConnectMethodStructureIStructureO(
+                                                 conn,
+						 index,
+						 sizeof(SMCParamStruct),
+						 &outSize,
+						 input,
+						 output);
+
     return result;
 }
 
