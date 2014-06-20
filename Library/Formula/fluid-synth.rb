require 'formula'

class FluidSynth < Formula
  homepage 'http://www.fluidsynth.org'
  url 'https://downloads.sourceforge.net/project/fluidsynth/fluidsynth-1.1.6/fluidsynth-1.1.6.tar.gz'
  sha1 '155de731e72e91e1d4b7f52c33d8171596fbf244'

  depends_on 'pkg-config' => :build
  depends_on 'cmake' => :build
  depends_on 'glib'
  depends_on 'libsndfile' => :optional
  depends_on :ld64
  
  patch :DATA if MacOS.version == :tiger

  fails_with :gcc do
    build 5553
    cause "/Developer/SDKs/MacOSX10.4u.sdk/usr/include/float.h:8:24: error: float.h: No such file or directory"
  end

  def install
    mkdir 'build' do
      system "cmake", "..", "-Denable-framework=OFF", "-DLIB_SUFFIX=", *std_cmake_args
      system "make install"
    end
  end
end
__END__
diff --git a/src/drivers/fluid_coreaudio.c b/src/drivers/fluid_coreaudio.c
index d7c22e3..ebb9c88 100644
--- a/src/drivers/fluid_coreaudio.c
+++ b/src/drivers/fluid_coreaudio.c
@@ -33,6 +33,23 @@
 #include "config.h"
 
 #if COREAUDIO_SUPPORT
+
+/* Work around for OSX 10.4 */
+
+/* enum definition in OpenTransportProviders.h defines these tokens
+   which are #defined from <netinet/tcp.h> */
+#ifdef TCP_NODELAY
+#undef TCP_NODELAY
+#endif
+#ifdef TCP_MAXSEG
+#undef TCP_MAXSEG
+#endif
+#ifdef TCP_KEEPALIVE
+#undef TCP_KEEPALIVE
+#endif
+
+/* End work around */
+
 #include <CoreServices/CoreServices.h>
 #include <CoreAudio/CoreAudioTypes.h>
 #include <CoreAudio/AudioHardware.h>
-- 
2.0.0
